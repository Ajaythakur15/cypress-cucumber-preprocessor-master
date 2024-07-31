@no-default-plugin
Feature: browserify + typescript
  Scenario:
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature name
        Scenario: a scenario name
          Given a step
      """
    And a file named "setupNodeEvents.js" with:
      """
      const browserify = require("@cypress/browserify-preprocessor");
      const { addCucumberPreprocessorPlugin } = require("@badeball/cypress-cucumber-preprocessor");
      const { preprocessor } = require("@badeball/cypress-cucumber-preprocessor/browserify");

      module.exports = async (on, config) => {
        await addCucumberPreprocessorPlugin(on, config);
        on(
          "file:preprocessor",
          preprocessor(config, {
            ...browserify.defaultOptions,
            typescript: require.resolve("typescript")
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
