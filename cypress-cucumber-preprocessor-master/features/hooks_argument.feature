Feature: hooks argument

  Rule: some hooks should be invoked with various arguments

    Scenario: Before hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { When, Before } = require("@badeball/cypress-cucumber-preprocessor");
        When("a step", function() {});
        Before(function ({ gherkinDocument, pickle, testCaseStartedId }) {
          expect(gherkinDocument.feature.name).to.equal("a feature name");
          expect(pickle.name).to.equal("a scenario name");
          expect(testCaseStartedId).to.be.a("string");
        });
        """
    When I run cypress
    Then it passes

    Scenario: After hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { When, Before } = require("@badeball/cypress-cucumber-preprocessor");
        When("a step", function() {});
        Before(function ({ gherkinDocument, pickle, testCaseStartedId, result, willBeRetried }) {
          expect(gherkinDocument.feature.name).to.equal("a feature name");
          expect(pickle.name).to.equal("a scenario name");
          expect(testCaseStartedId).to.be.a("string");
        });
        """
    When I run cypress
    Then it passes

    Scenario: BeforeStep hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { When, BeforeStep } = require("@badeball/cypress-cucumber-preprocessor");
        When("a step", function() {});
        BeforeStep(function ({ pickle, pickleStep, gherkinDocument, testCaseStartedId, testStepId }) {
          expect(pickle.name).to.equal("a scenario name");
          expect(pickleStep.text).to.equal("a step");
          expect(gherkinDocument.feature.name).to.equal("a feature name");
          expect(testCaseStartedId).to.be.a("string");
          expect(testStepId).to.be.a("string");
        });
        """
    When I run cypress
    Then it passes

    Scenario: AfterStep hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { When, AfterStep } = require("@badeball/cypress-cucumber-preprocessor");
        When("a step", function() {});
        AfterStep(function ({ pickle, pickleStep, gherkinDocument, testCaseStartedId, testStepId }) {
          expect(pickle.name).to.equal("a scenario name");
          expect(pickleStep.text).to.equal("a step");
          expect(gherkinDocument.feature.name).to.equal("a feature name");
          expect(testCaseStartedId).to.be.a("string");
          expect(testStepId).to.be.a("string");
        });
        """
    When I run cypress
    Then it passes
