Feature: merging reports

  Scenario: two features
    Given additional preprocessor configuration
      """
      {
        "messages": {
          "enabled": true
        }
      }
      """
    And a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a step
      """
    And a file named "cypress/e2e/b.feature" with:
      """
      Feature: another feature
        Scenario: another scenario
          Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", function() {})
      """
    When I run cypress with "--spec cypress/e2e/a.feature --env messagesOutput=cucumber-messages-a.ndjson" (expecting exit code 0)
    And I run cypress with "--spec cypress/e2e/b.feature --env messagesOutput=cucumber-messages-b.ndjson" (expecting exit code 0)
    And I merge the messages reports
    Then there should be a messages similar to "fixtures/multiple-features.ndjson"
