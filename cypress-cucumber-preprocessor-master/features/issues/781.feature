# https://github.com/badeball/cypress-cucumber-preprocessor/issues/781

Feature: non-array step definitions, not matching
  Scenario: non-array step definitions, not matching
    Given additional preprocessor configuration
      """
      {
        "stepDefinitions": "foo/bar"
      }
      """
    And a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an undefined step
      """
    When I run cypress
    Then it fails
    And the output should contain
      """
      Step implementation missing for "an undefined step".

      We tried searching for files containing step definitions using the following search pattern templates:

        - foo/bar

      These templates resolved to the following search patterns:

        - foo/bar

      These patterns matched **no files** containing step definitions. This almost certainly means that you have misconfigured `stepDefinitions`.
      """
