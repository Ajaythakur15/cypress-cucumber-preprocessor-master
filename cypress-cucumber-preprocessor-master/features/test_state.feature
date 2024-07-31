Feature: window.testState
  Scenario: gherkin document
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature name
        Scenario: a scenario name
          Given a step
      """
    And a file named "cypress/e2e/a.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", function() {
        expect(testState.gherkinDocument.feature.name).to.equal("a feature name");
      });
      """
    When I run cypress
    Then it passes

  Scenario: pickles
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature name
        Scenario: a scenario name
          Given a step
      """
    And a file named "cypress/e2e/a.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", function() {
        expect(testState.pickles[0].name).to.equal("a scenario name");
      });
      """
    When I run cypress
    Then it passes

  Scenario: pickle
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature name
        Scenario: a scenario name
          Given a step
      """
    And a file named "cypress/e2e/a.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", function() {
        expect(testState.pickle.name).to.equal("a scenario name");
      });
      """
    When I run cypress
    Then it passes

  Scenario: pickleStep
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature name
        Scenario: a scenario name
          Given a step
          And another step
      """
    And a file named "cypress/e2e/a.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", function() {
        expect(testState.pickleStep.text).to.equal("a step");
      });
      Given("another step", function() {
        expect(testState.pickleStep.text).to.equal("another step");
      });
      """
    When I run cypress
    Then it passes
