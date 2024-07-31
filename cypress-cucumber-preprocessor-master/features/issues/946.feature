# https://github.com/badeball/cypress-cucumber-preprocessor/issues/946

Feature: spec names containing glob specific characters
  Scenario: spec names containing glob specific characters
    Given a file named "cypress/e2e/[foo].feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a step
      """
    And a file named "cypress/e2e/[foo].js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", function() {})
      """
    When I run cypress
    Then it passes
