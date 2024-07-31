Feature: diagnostics
  Rule: usage should be grouped by step definition
    Scenario: one definition
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {});
        """
      When I run diagnostics
      Then the output should contain
        """
        ┌────────────────┬─────────────────────────────────────────────┐
        │ Pattern / Text │ Location                                    │
        ├────────────────┼─────────────────────────────────────────────┤
        │ 'a step'       │ cypress/support/step_definitions/steps.js:2 │
        │   a step       │ cypress/e2e/a.feature:3                     │
        └────────────────┴─────────────────────────────────────────────┘
        """

    Scenario: one definition, repeated
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
            And a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {});
        """
      When I run diagnostics
      Then the output should contain
        """
        ┌────────────────┬─────────────────────────────────────────────┐
        │ Pattern / Text │ Location                                    │
        ├────────────────┼─────────────────────────────────────────────┤
        │ 'a step'       │ cypress/support/step_definitions/steps.js:2 │
        │   a step       │ cypress/e2e/a.feature:3                     │
        │   a step       │ cypress/e2e/a.feature:4                     │
        └────────────────┴─────────────────────────────────────────────┘
        """

    Scenario: two definitions
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
            And another step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {});
        Given("another step", function() {});
        """
      When I run diagnostics
      Then the output should contain
        """
        ┌────────────────┬─────────────────────────────────────────────┐
        │ Pattern / Text │ Location                                    │
        ├────────────────┼─────────────────────────────────────────────┤
        │ 'a step'       │ cypress/support/step_definitions/steps.js:2 │
        │   a step       │ cypress/e2e/a.feature:3                     │
        ├────────────────┼─────────────────────────────────────────────┤
        │ 'another step' │ cypress/support/step_definitions/steps.js:3 │
        │   another step │ cypress/e2e/a.feature:4                     │
        └────────────────┴─────────────────────────────────────────────┘
        """

  Rule: it should report any problem
    Scenario: no step definition files
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      When I run diagnostics
      Then it fails
      And the output should contain
        """
        Found 1 problem(s):

        1) Error: Step implementation missing at cypress/e2e/a.feature:3

             a step

           We tried searching for files containing step definitions using the following search pattern template(s):

             - cypress/e2e/[filepath]/**/*.{js,mjs,ts,tsx}
             - cypress/e2e/[filepath].{js,mjs,ts,tsx}
             - cypress/support/step_definitions/**/*.{js,mjs,ts,tsx}

           These templates resolved to the following search pattern(s):

             - cypress/e2e/a/**/*.{js,mjs,ts,tsx}
             - cypress/e2e/a.{js,mjs,ts,tsx}
             - cypress/support/step_definitions/**/*.{js,mjs,ts,tsx}

           These patterns matched *no files* containing step definitions. This almost certainly means that you have misconfigured `stepDefinitions`. Alternatively, you can implement it using the suggestion(s) below.

             Given("a step", function () {
               return "pending";
             });
        """

    Scenario: step defintions, but none matching
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("another step", function() {});
        """
      When I run diagnostics
      Then it fails
      And the output should contain
        """
        Found 1 problem(s):

        1) Error: Step implementation missing at cypress/e2e/a.feature:3

             a step

           We tried searching for files containing step definitions using the following search pattern template(s):

             - cypress/e2e/[filepath]/**/*.{js,mjs,ts,tsx}
             - cypress/e2e/[filepath].{js,mjs,ts,tsx}
             - cypress/support/step_definitions/**/*.{js,mjs,ts,tsx}

           These templates resolved to the following search pattern(s):

             - cypress/e2e/a/**/*.{js,mjs,ts,tsx}
             - cypress/e2e/a.{js,mjs,ts,tsx}
             - cypress/support/step_definitions/**/*.{js,mjs,ts,tsx}

           These patterns matched the following file(s):

             - cypress/support/step_definitions/steps.js

           However, none of these files contained a matching step definition. You can implement it using the suggestion(s) below.

             Given("a step", function () {
               return "pending";
             });
        """

    Scenario: ambiguous step
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {});
        Given(/a step/, function() {});
        """
      When I run diagnostics
      Then it fails
      And the output should contain
        """
        Found 1 problem(s):

        1) Error: Multiple matching step definitions at cypress/e2e/a.feature:3 for

             a step

           Step matched the following definitions:

             - 'a step' (cypress/support/step_definitions/steps.js:2)
             - /a step/ (cypress/support/step_definitions/steps.js:3)
        """

    Scenario: module package
      Given a file named "package.json" with:
        """
        {
          "type": "module"
        }
        """
      And a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        import { Given } from "@badeball/cypress-cucumber-preprocessor";
        Given("a step", function() {});
        """
      When I run diagnostics
      Then the output should contain
        """
        ┌────────────────┬─────────────────────────────────────────────┐
        │ Pattern / Text │ Location                                    │
        ├────────────────┼─────────────────────────────────────────────┤
        │ 'a step'       │ cypress/support/step_definitions/steps.js:2 │
        │   a step       │ cypress/e2e/a.feature:3                     │
        └────────────────┴─────────────────────────────────────────────┘
        """

  Rule: it should works despite accessing a variety of globals on root-level

    Scenario: Cypress.env
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        const foo = Cypress.env("foo");
        Given("a step", function() {});
        """
      When I run diagnostics
      Then the output should contain
        """
        ┌────────────────┬─────────────────────────────────────────────┐
        │ Pattern / Text │ Location                                    │
        ├────────────────┼─────────────────────────────────────────────┤
        │ 'a step'       │ cypress/support/step_definitions/steps.js:3 │
        │   a step       │ cypress/e2e/a.feature:3                     │
        └────────────────┴─────────────────────────────────────────────┘
        """

    Scenario: Cypress.on
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Cypress.on("uncaught:exception", () => {});
        Given("a step", function() {});
        """
      When I run diagnostics
      Then the output should contain
        """
        ┌────────────────┬─────────────────────────────────────────────┐
        │ Pattern / Text │ Location                                    │
        ├────────────────┼─────────────────────────────────────────────┤
        │ 'a step'       │ cypress/support/step_definitions/steps.js:3 │
        │   a step       │ cypress/e2e/a.feature:3                     │
        └────────────────┴─────────────────────────────────────────────┘
        """

    Scenario: Cypress.config
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        const foo = Cypress.config("foo");
        Given("a step", function() {});
        """
      When I run diagnostics
      Then the output should contain
        """
        ┌────────────────┬─────────────────────────────────────────────┐
        │ Pattern / Text │ Location                                    │
        ├────────────────┼─────────────────────────────────────────────┤
        │ 'a step'       │ cypress/support/step_definitions/steps.js:3 │
        │   a step       │ cypress/e2e/a.feature:3                     │
        └────────────────┴─────────────────────────────────────────────┘
        """
