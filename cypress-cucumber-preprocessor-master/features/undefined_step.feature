Feature: undefined Steps

  Rule: it should output appropriate path info

    Scenario: no files containing step definitions
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given an undefined step
        """
      When I run cypress
      Then it fails
      And the output should contain
        """
        Step implementation missing for "an undefined step".

        We tried searching for files containing step definitions using the following search pattern templates:

          - cypress/e2e/[filepath]/**/*.{js,mjs,ts,tsx}
          - cypress/e2e/[filepath].{js,mjs,ts,tsx}
          - cypress/support/step_definitions/**/*.{js,mjs,ts,tsx}

        These templates resolved to the following search patterns:

          - cypress/e2e/a/**/*.{js,mjs,ts,tsx}
          - cypress/e2e/a.{js,mjs,ts,tsx}
          - cypress/support/step_definitions/**/*.{js,mjs,ts,tsx}

        These patterns matched **no files** containing step definitions. This almost certainly means that you have misconfigured `stepDefinitions`.
        """

    Scenario: step definitions exist, but none matching
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given an undefined step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { When } = require("@badeball/cypress-cucumber-preprocessor");
        When("unused step definition", function() {});
        """
      When I run cypress
      Then it fails
      And the output should contain
        """
        Step implementation missing for "an undefined step".

        We tried searching for files containing step definitions using the following search pattern templates:

          - cypress/e2e/[filepath]/**/*.{js,mjs,ts,tsx}
          - cypress/e2e/[filepath].{js,mjs,ts,tsx}
          - cypress/support/step_definitions/**/*.{js,mjs,ts,tsx}

        These templates resolved to the following search patterns:

          - cypress/e2e/a/**/*.{js,mjs,ts,tsx}
          - cypress/e2e/a.{js,mjs,ts,tsx}
          - cypress/support/step_definitions/**/*.{js,mjs,ts,tsx}

        These patterns matched the following files:

          - cypress/support/step_definitions/steps.js

        However, none of these files contained a step definition matching "an undefined step".
        """

  Rule: it should output snippet suggestions

    Scenario: undefined step without args
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given an undefined step
        """
      When I run cypress
      Then it fails
      And the output should contain
        """
        You can implement it using the suggestion(s) below.

          Given("an undefined step", function () {
            return "pending";
          });
        """

    Scenario: undefined step with doc string
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given an undefined step
              \"\"\"
              foo
              \"\"\"
        """
      When I run cypress
      Then it fails
      And the output should contain
        """
        You can implement it using the suggestion(s) below.

          Given("an undefined step", function (docString) {
            return "pending";
          });
        """

    Scenario: undefined step with data table
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given an undefined step
             | foo |
             | bar |
        """
      When I run cypress
      Then it fails
      And the output should contain
        """
        You can implement it using the suggestion(s) below.

          Given("an undefined step", function (dataTable) {
            return "pending";
          });
        """
