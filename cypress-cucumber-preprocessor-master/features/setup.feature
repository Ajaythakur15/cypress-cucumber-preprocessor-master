@no-default-plugin
Feature: setup
  Scenario: missing addCucumberPreprocessorPlugin in setupNodeEvents
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature name
        Scenario: a scenario name
          Given a step
      """
    And a file named "setupNodeEvents.js" with:
      """
      const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");
      const { createEsbuildPlugin } = require("@badeball/cypress-cucumber-preprocessor/esbuild");

      module.exports = async (on, config) => {
        on(
          "file:preprocessor",
          createBundler({
            plugins: [createEsbuildPlugin(config)]
          })
        );
      };
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      import { Given } from "@badeball/cypress-cucumber-preprocessor";
      Given("a step", function() {});
      """
    When I run cypress
    Then it fails
    And the output should contain
      """
      Missing preprocessor event handlers (this usually means you've not invoked `addCucumberPreprocessorPlugin()` or not returned the config object in `setupNodeEvents()`)
      """
