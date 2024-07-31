# https://github.com/badeball/cypress-cucumber-preprocessor/issues/1034

Feature: HTML report
  Scenario: skipepd test
    Given additional preprocessor configuration
      """
      {
        "html": {
          "enabled": true
        }
      }
      """
    And a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        @skip
        Scenario: a scenario
          Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", function() {});
      """
    When I run cypress
    Then it passes
    And the HTML report should display 1 "skipped" scenario
