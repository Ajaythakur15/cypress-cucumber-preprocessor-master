Feature: world

  Rule: `this` is a shared context between all functions

    Background:
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/set-world.js" with:
        """
        beforeEach(function () {
          this.isWorld = true;
        });
        """

    Scenario: world is `this` in Before hooks
      Given a file named "cypress/e2e/a.js" with:
        """
        const { Before, Given } = require("@badeball/cypress-cucumber-preprocessor");
        Before(function () {
          expect(this.isWorld).to.be.true;
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: world is `this` in After hooks
      Given a file named "cypress/e2e/a.js" with:
        """
        const { After, Given } = require("@badeball/cypress-cucumber-preprocessor");
        After(function () {
          expect(this.isWorld).to.be.true;
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: world is `this` in BeforeStep hooks
      Given a file named "cypress/e2e/a.js" with:
        """
        const { BeforeStep, Given } = require("@badeball/cypress-cucumber-preprocessor");
        BeforeStep(function () {
          expect(this.isWorld).to.be.true;
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: world is `this` in AfterStep hooks
      Given a file named "cypress/e2e/a.js" with:
        """
        const { AfterStep, Given } = require("@badeball/cypress-cucumber-preprocessor");
        AfterStep(function () {
          expect(this.isWorld).to.be.true;
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: world is `this` in afterEach hooks
      Given a file named "cypress/e2e/a.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        afterEach(function () {
          expect(this.isWorld).to.be.true;
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: world is `this` in nested steps
      Given a file named "cypress/e2e/a.js" with:
        """
        const { Step, Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {
          Step(this, "nested step");
        });
        Given("nested step", function() {
          expect(this.isWorld).to.be.true;
        });
        """
      When I run cypress
      Then it passes
