@no-default-plugin
Feature: esbuild + typescript
  Scenario:
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature name
        Scenario: a scenario name
          Given a step
      """
    And a file named "setupNodeEvents.js" with:
      """
      const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");
      const { addCucumberPreprocessorPlugin } = require("@badeball/cypress-cucumber-preprocessor");
      const { createEsbuildPlugin } = require("@badeball/cypress-cucumber-preprocessor/esbuild");

      module.exports = async (on, config) => {
        await addCucumberPreprocessorPlugin(on, config);
        on(
          "file:preprocessor",
          createBundler({
            plugins: [createEsbuildPlugin(config)]
          })
        );
        return config;
      };
      """
    And a file named "cypress/support/step_definitions/steps.ts" with:
      """
      import { Given } from "@badeball/cypress-cucumber-preprocessor";
      Given("a step", function(this: Mocha.Context) {});
      """
    When I run cypress
    Then it passes
