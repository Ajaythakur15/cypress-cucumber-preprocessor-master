# https://github.com/badeball/cypress-cucumber-preprocessor/issues/944

@network
Feature: changing domain during a spec
  Background:
    Given additional preprocessor configuration
      """
      {
        "json": {
          "enabled": true
        }
      }
      """

  Scenario:
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          When I navigate to "https://duckduckgo.com/"

        Scenario: a scenario
          When I navigate to "https://google.com/"
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { When } = require("@badeball/cypress-cucumber-preprocessor");
      When("I navigate to {string}", function(url) {
        cy.visit(url)
      })
      """
    When I run cypress
    Then it passes
    And the JSON report should contain 2 tests
