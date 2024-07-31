# https://github.com/badeball/cypress-cucumber-preprocessor/issues/813

Feature: messages report
  Scenario: it should only ever contain one 'testRunStarted' and 'testRunFinished'
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
          Given a step
      """
    And a file named "cypress/e2e/b.feature" with:
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
    And the messages should only contain a single "testRunStarted" and a single "testRunFinished"
