# https://github.com/badeball/cypress-cucumber-preprocessor/issues/963

Feature: message timestamps
  Scenario: failing step
    Given additional preprocessor configuration
      """
      {
        "messages": {
          "enabled": true
        }
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
        cy.wait(1000).then(() => { throw "some error" })
      })
      """
    When I run cypress
    Then it fails
    And the message report should contain a non-zero duration of the step
