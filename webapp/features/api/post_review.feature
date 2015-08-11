Feature: API
  Background:
    Given all data are prepared

  Scenario: Post a review for physician
    When I send and accept JSON

    And I send a POST request to "/v1/account/session" with the following:
      """
      {"user":{"email":"test@thecarevoice.com","password":"123456"}}
      """
    Then the response status should be "201"

    When I send a GET request to "/v1/search/physicians?name=test"
    Then the response status should be "200"
    And the JSON response should have "$..name" with the text "test 123"
    And the JSON response should have "$..name" with the text "test 321"

    When I send a POST "physician" review request to "/v1/reviews/physician" for name "test 321" and the following:
      """
      {"review":{"note":"good doctor"}}
      """
    Then the response status should be "201"

    When I send a GET "physician" review request to "/v1/reviews/:id" for review note "good doctor"
    Then the response status should be "200"
    And the JSON response should have "$..note" with the text "good doctor"

  Scenario: Post a review for medication
    When I send and accept JSON

    And I send a POST request to "/v1/account/session" with the following:
      """
      {"user":{"email":"test@thecarevoice.com","password":"123456"}}
      """
    Then the response status should be "201"

    When I send a GET request to "/v1/search/medications?name=test"
    Then the response status should be "200"
    And the JSON response should have "$..name" with the text "test 123"
    And the JSON response should have "$..name" with the text "tset 123"

    When I send a POST "medication" review request to "/v1/reviews/medication" for name "test 123" and the following:
      """
      {"review":{"note":"good medication"}}
      """
    Then the response status should be "201"

    When I send a GET "medication" review request to "/v1/reviews/:id" for review note "good medication"
    Then the response status should be "200"
    And the JSON response should have "$..note" with the text "good medication"

  Scenario: Post a review for hospital
    When I send and accept JSON

    And I send a POST request to "/v1/account/session" with the following:
      """
      {"user":{"email":"test@thecarevoice.com","password":"123456"}}
      """
    Then the response status should be "201"

    When I send a GET request to "/v1/search/hospitals/by_name?name=Shanghai"
    Then the response status should be "200"
    And the JSON response should have "$..name" with the text "Shanghai Hospital"
    And the JSON response should have "$..name" with the text "Shanghai Ruijing Hospital"

    When I send a POST "hospital" review request to "/v1/reviews/hospital" for name "Shanghai Hospital" and the following:
      """
      {"review":{"note":"good hospital"}}
      """
    Then the response status should be "201"

    When I send a GET "hospital" review request to "/v1/reviews/:id" for review note "good hospital"
    Then the response status should be "200"
    And the JSON response should have "$..note" with the text "good hospital"
