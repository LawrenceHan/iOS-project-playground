(function($) {
    // This binds binds a callback to 'this' element so that when the user scrolls
    // to the 'lastCell', the 'loadMore' function is called ONCE.
    //
    // If you have even more to load, call the second param of your 'loadMore' function,
    // which will be the function 'bindLoadMore' below.
    //
    // Example: /mobile/physicians/index
    //
    // Params:
    //   lastCell: the selector for selecting the lastCell
    //   loadMore: a function which is called when you scroll to the 'lastCell'
    $.fn.bindLoadMore = function(lastCell, loadMore) {
        /**************** Class Page ********************/
        function Page() {
            this.page = 1;
        }

        // Method: get() - return the page value
        Page.prototype.get = function() {
            return this.page;
        };

        // Method: increment()
        Page.prototype.increment = function() {
            this.page++;
        };

        /************** End Class Page ******************/

        var pageObj = new Page(),
        hasMore = true,
        $window = $(window),
        $lastCell;

        function windowDidScroll() {
            if ($lastCell.offset().top < $window.scrollTop() + $window.height()) {
                $window.off('scroll', windowDidScroll);
                //
                // pageObj: a wrapper object for the page number
                // bindLoadMore:  if you think that there
                //               is still more to load, you can simply call this again
                loadMore(pageObj, bindLoadMore);
            }
        }

        function bindLoadMore() {
            $lastCell = $(lastCell);
            $window.scroll(windowDidScroll);
        }


        bindLoadMore();
    };

    //
    // A typical application of bindLoadMore function, with a loaded callback
    //
    // loaded: function(hasMore) {} - a function which will be called when a page is loaded
    //
    $.fn.loadMore = function(lastCell, loaded, callback) {
        var $container = this,
        hasMore = true,
        pageUrl = window.location.toString();


        if (hasMore) {
            $container.bindLoadMore(lastCell, function(pageObj, bindAgain) {
                $.get(pageUrl, { 'page': pageObj.get() + 1 }, function(data, status, jqXHR) {
                    $(data).appendTo($container);
                    if(typeof(callback) != "undefined"){
                        callback();
                    }
                    pageObj.increment();
                    hasMore = !!jqXHR.getResponseHeader('X-HAS-MORE');
                    if (hasMore) {
                        bindAgain();
                    }

                    if ($.isFunction(loaded)) {
                        loaded(hasMore);
                    }
                });
            });
        }

    };


})(jQuery);
