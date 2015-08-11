Feature: API
  Scenario: Sign up and sign in
    When I send and accept JSON

    And I send a POST request to "/v1/account/register/sms_sending" with the following:
      """
      {"phone":"12345678901"}
      """
    Then the response status should be "201"

    When I send a POST request to "/v1/account/register" with the following:
      """
      {"user":{"email":"new_user@thecarevoice.com","password":"123456","phone":"12345678901","sms_token":"1234"}}
      """
    Then the response status should be "201"

    When I send a DELETE request to "/v1/account/session"
    Then the response status should be "204"

    When I send a POST request to "/v1/account/session" with the following:
    """
    {"user":{"email":"new_user@thecarevoice.com","password":"123456"}}
    """
    Then the response status should be "201"

    When I send a DELETE request to "/v1/account/session"
    Then the response status should be "204"
