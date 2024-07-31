# https://github.com/badeball/cypress-cucumber-preprocessor/issues/856

Feature: swallowing exceptions
  Background:
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a failing step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a failing step", function() {
        throw new Error("foobar")
      })
      """

  Scenario: without swallowing
    When I run cypress
    Then it fails

  Scenario: with swallowing
    Given a file named "cypress/support/e2e.js" with:
      """
      Cypress.on("fail", (err) => {
        if (err.message.includes("foobar")) {
          return;
        }

        throw err;
      })
      """
    When I run cypress
    Then it passes
