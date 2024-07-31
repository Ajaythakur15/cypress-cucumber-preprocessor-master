# https://github.com/badeball/cypress-cucumber-preprocessor/issues/1091

@network
Feature: pretty output
  Scenario: reload-behavior in before hook
    Given additional Cypress configuration
      """
      {
        "reporter": "@badeball/cypress-cucumber-preprocessor/dist/subpath-entrypoints/pretty-reporter.js"
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
      before(() => {
        cy.visit("https://duckduckgo.com/");
      });
      """
    When I run cypress
    Then it passes
