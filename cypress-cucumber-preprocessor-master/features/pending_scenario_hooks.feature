Feature: pending scenario hooks

  Scenario: pending Before() hook
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Before, Given } = require("@badeball/cypress-cucumber-preprocessor")
      Before(() => {
        return "pending"
      })
      Given("a step", function() {})
      """
    When I run cypress
    Then it passes
    And it should appear to have skipped the scenario "a scenario"

  Scenario: pending After() hook
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { After, Given } = require("@badeball/cypress-cucumber-preprocessor")
      After(() => {
        return "pending"
      })
      Given("a step", function() {})
      """
    When I run cypress
    Then it passes
    And it should appear to have skipped the scenario "a scenario"
