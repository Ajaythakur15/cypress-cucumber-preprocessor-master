Feature: pending steps
  Background:
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a pending step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor")
      Given("a pending step", function() {
        return "pending"
      })
      """

  Rule: pending steps make the test skipped

    Scenario: basic pending step
      When I run cypress
      Then it passes
      And it should appear to have skipped the scenario "a scenario"

    Scenario: with step hooks returning strings
      Given a file named "cypress/support/step_definitions/hooks.js" with:
        """
        const { BeforeStep, AfterStep } = require("@badeball/cypress-cucumber-preprocessor")
        BeforeStep(function() {
          return "foobar"
        })
        AfterStep(function() {
          return "foobar"
        })
        """
      When I run cypress
      Then it passes
      And it should appear to have skipped the scenario "a scenario"

    Scenario: with step hooks returning chains
      Given a file named "cypress/support/step_definitions/hooks.js" with:
        """
        const { BeforeStep, AfterStep } = require("@badeball/cypress-cucumber-preprocessor")
        BeforeStep(function() {
          return cy.wrap("foobar")
        })
        AfterStep(function() {
          return cy.wrap("foobar")
        })
        """
      When I run cypress
      Then it passes
      And it should appear to have skipped the scenario "a scenario"

