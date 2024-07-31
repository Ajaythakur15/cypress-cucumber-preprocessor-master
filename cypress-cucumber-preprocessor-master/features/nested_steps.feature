Feature: nesten steps

  Scenario: invoking step from another step
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature name
        Scenario: a scenario name
          Given a nested step
      """
    And a file named "cypress/e2e/a.js" with:
      """
      const { Given, Step } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a nested step", function() {
        Step(this, "another step");
        cy.get("@bar").should("equal", "foo");
      });
      Given("another step", function() {
        cy.wrap("foo").as("bar");
      });
      """
    When I run cypress
    Then it passes
