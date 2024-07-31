# https://github.com/badeball/cypress-cucumber-preprocessor/issues/795

Feature: scenario outline with parameterized name
  Scenario: scenario outline with parameterized name
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
        Scenario Outline: <value>
          Given a step

          Examples:
            | value |
            | foo   |
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", () => {})
      """
    When I run cypress
    Then it passes
    And there should be a JSON output similar to "fixtures/parameterized-scenario-name.json"
