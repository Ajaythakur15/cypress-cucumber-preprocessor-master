# https://github.com/badeball/cypress-cucumber-preprocessor/issues/1142

@network
Feature: JSON report
  Scenario: reload-behavior in beforeEach hook
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
    And a file named "cypress/support/e2e.js" with:
      """
      beforeEach(() => {
        cy.visit("https://duckduckgo.com/");
      });
      """
    When I run cypress
    Then it passes
