# https://github.com/badeball/cypress-cucumber-preprocessor/issues/749

Feature: retried steps
  Scenario: forever failing
    Given additional Cypress configuration
      """
      {
        "retries": 2
      }
      """
    And a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a failing step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a failing step", function() {
        throw "some error"
      })
      """
    When I run cypress
    Then it fails
