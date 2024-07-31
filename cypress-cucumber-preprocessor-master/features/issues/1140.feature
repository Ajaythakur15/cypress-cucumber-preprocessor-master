# https://github.com/badeball/cypress-cucumber-preprocessor/issues/1140

Feature: no imlicit report
  Scenario: JSON enabled
    Given additional preprocessor configuration
      """
      {
        "json": {
          "enabled": true
        }
      }
      """
    And a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", function() {})
      """
    When I run cypress
    Then it passes
    And there should be a JSON output similar to "fixtures/passed-example.json"
    And there should be no messages report
