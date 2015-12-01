#import "MPAdBrowserController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdBrowserControllerSpec)

describe(@"MPAdBrowserController", ^{
    __block UIViewController *presentingViewController;
    __block MPAdBrowserController *browser;
    __block id<CedarDouble, MPAdBrowserControllerDelegate> delegate;
    __block NSURL *URL;

    beforeEach(^{
        presentingViewController = [[UIViewController alloc] init];

        URL = [NSURL URLWithString:@"http://www.apple.com"];
        delegate = nice_fake_for(@protocol(MPAdBrowserControllerDelegate));
        browser = [[MPAdBrowserController alloc] initWithURL:URL
                                                   HTMLString:@"<h1>Hello</h1>"
                                                     delegate:delegate];

        browser.view should_not be_nil;

        // ios 7 is unhappy if a UIActionSheet attempts to display from a view
        // that's not attached to a window
        UIWindow *window = [[UIWindow alloc] init];
        [window addSubview:browser.view];

        [browser viewWillAppear:NO];
        [browser viewDidAppear:NO];

        [presentingViewController presentViewController:browser animated:NO completion:nil];
        presentingViewController.presentedViewController should be_same_instance_as(browser);
    });

    describe(@"after the view appears", ^{
        it(@"should set the HTMLString and baseURL properly", ^{
            [browser.webView loadedHTMLString] should equal(@"<h1>Hello</h1>");
            [browser.webView loadedBaseURL] should equal(URL);
        });

        it(@"should disable the navigation buttons", ^{
            browser.backButton.enabled should equal(NO);
            browser.forwardButton.enabled should equal(NO);
            browser.refreshButton.enabled should equal(NO);
            browser.safariButton.enabled should equal(NO);
        });
    });

    describe(@"tapping toolbar buttons", ^{
        __block UIBarButtonItem *buttonUnderTest;

        beforeEach(^{
            // HACK: PivotalCoreKit's spec helpers for UIBarButtonItem now prohibit tapping on
            // disabled buttons. Just enable all our buttons to avoid exceptions.
            browser.backButton.enabled = YES;
            browser.forwardButton.enabled = YES;
            browser.refreshButton.enabled = YES;
            browser.safariButton.enabled = YES;
        });

        sharedExamplesFor(@"an MPAdBrowser toolbar button that hides the action sheet", ^(NSDictionary *sharedContext) {
            beforeEach(^{
                [browser.safariButton tap];
                [UIActionSheet currentActionSheet] should_not be_nil;
                [buttonUnderTest tap];
            });

            it(@"should hide the action sheet", ^{
                [UIActionSheet currentActionSheet] should be_nil;
            });
        });

        describe(@"when the user taps the Done button", ^{
            subjectAction(^{
                [browser.doneButton tap];
            });

            beforeEach(^{
                buttonUnderTest = browser.doneButton;
            });

            it(@"should tell its delegate to dismiss itself", ^{
                delegate should have_received(@selector(dismissBrowserController:animated:));
            });

            itShouldBehaveLike(@"an MPAdBrowser toolbar button that hides the action sheet");

            context(@"if the browser has no delegate", ^{
                beforeEach(^{
                    browser.delegate = nil;
                });

                it(@"should still dismiss itself", ^{
                    presentingViewController.presentedViewController should be_nil;
                });

                itShouldBehaveLike(@"an MPAdBrowser toolbar button that hides the action sheet");
            });
        });

        describe(@"when the user taps the Safari button", ^{
            beforeEach(^{
                buttonUnderTest = browser.safariButton;
                [browser.safariButton tap];
            });

            it(@"should present an action sheet", ^{
                [UIActionSheet currentActionSheet] should_not be_nil;
                [[UIActionSheet currentActionSheet] buttonTitles] should equal(@[@"Open in Safari", @"Cancel"]);
            });

            it(@"should toggle the action sheet when tapped again and again", ^{
                [browser.safariButton tap];
                [UIActionSheet currentActionSheet] should be_nil;

                [browser.safariButton tap];
                [UIActionSheet currentActionSheet] should_not be_nil;
            });

            context(@"when the user taps the Open in Safari action sheet button", ^{
                it(@"should open the current page in Safari", ^{
                    [[UIActionSheet currentActionSheet] dismissByClickingButtonWithTitle:@"Open in Safari"];
                    [[UIApplication sharedApplication] lastOpenedURL] should equal(URL);
                });
            });
        });
    });

    describe(@"as the user browses", ^{
        it(@"should keep the URL up to date", ^{
            NSURL *newURL = [NSURL URLWithString:@"http://newguy.com"];
            [browser.webView sendClickRequest:[NSURLRequest requestWithURL:newURL]];

            [browser.safariButton tap];
            [[UIActionSheet currentActionSheet] dismissByClickingButtonWithTitle:@"Open in Safari"];
            [[UIApplication sharedApplication] lastOpenedURL] should equal(newURL);
        });
    });

    describe(@"the spinner", ^{
        it(@"should start and stop correctly", ^{
            [browser webViewDidStartLoad:browser.webView];
            browser.spinner.isAnimating should be_truthy;

            [browser webViewDidStartLoad:browser.webView];

            [browser webViewDidFinishLoad:browser.webView];
            browser.spinner.isAnimating should be_truthy;

            [browser webViewDidFinishLoad:browser.webView];
            browser.spinner.isAnimating should_not be_truthy;
        });
    });
});

SPEC_END
