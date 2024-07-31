# https://github.com/badeball/cypress-cucumber-preprocessor/issues/931

Feature: screenshot of last, failed attempt
  Background:
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
          Given a failing step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a failing step", function() {
        throw new Error("foobar")
      })
      """

  Scenario: retries: 0
    When I run cypress
    Then it fails
    And the report should have an image attachment

  Scenario: retries: 1
    Given additional Cypress configuration
      """
      {
        "retries": 1
      }
      """
    When I run cypress
    Then it fails
    # «Still have», despite having been retried
    And the report should have an image attachment
