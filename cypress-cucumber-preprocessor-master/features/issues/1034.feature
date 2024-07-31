# https://github.com/badeball/cypress-cucumber-preprocessor/issues/1034

Feature: HTML report
  Scenario: one failed, one passed
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
        Scenario: a scenario
          Given a step
        Scenario: another scenario
          Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { After, Given } = require("@badeball/cypress-cucumber-preprocessor");
      let i = 0;
      Given("a step", function() {
        if (i++ === 0) {
          throw "some error";
        }
      });
      After(function() {});
      """
    When I run cypress
    Then it fails
    And the HTML should display 50% passed scenarios
