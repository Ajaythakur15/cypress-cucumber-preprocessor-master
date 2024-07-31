Feature: asynchronous world

  Rule: functions are scheduled asynchronously, permitting use of `this` more freely

    Scenario: asynchronous steps
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
          cy.then(() => this.isWorld = true);
        });
        Given("another step", function() {
          expect(this.isWorld).to.be.true;
        });
        """
      When I run cypress
      Then it passes

    Scenario: asynchronous nested steps
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/e2e/a.js" with:
        """
        const { Step, Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {
          Step(this, "a nested step");
          Step(this, "another nested step");
        });
        Given("a nested step", function() {
          cy.then(() => this.isWorld = true);
        });
        Given("another nested step", function() {
          expect(this.isWorld).to.be.true;
        });
        """
      When I run cypress
      Then it passes

    Scenario: asynchronous Before hooks
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/e2e/a.js" with:
        """
        const { Before, Given } = require("@badeball/cypress-cucumber-preprocessor");
        Before(function() {
          cy.then(() => this.isWorld = true);
        });
        Before(function() {
          expect(this.isWorld).to.be.true;
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: asynchronous After hooks
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/e2e/a.js" with:
        """
        const { After, Given } = require("@badeball/cypress-cucumber-preprocessor");
        After(function() {
          expect(this.isWorld).to.be.true;
        });
        After(function() {
          cy.then(() => this.isWorld = true);
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: asynchronous BeforeStep hooks
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/e2e/a.js" with:
        """
        const { BeforeStep, Given } = require("@badeball/cypress-cucumber-preprocessor");
        BeforeStep(function() {
          cy.then(() => this.isWorld = true);
        });
        BeforeStep(function() {
          expect(this.isWorld).to.be.true;
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: asynchronous AfterStep hooks
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/e2e/a.js" with:
        """
        const { AfterStep, Given } = require("@badeball/cypress-cucumber-preprocessor");
        // AfterStep hooks are executed in the reverse order that they were defined.
        AfterStep(function() {
          expect(this.isWorld).to.be.true;
        });
        AfterStep(function() {
          cy.then(() => this.isWorld = true);
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes
