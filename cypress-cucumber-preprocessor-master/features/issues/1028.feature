# https://github.com/badeball/cypress-cucumber-preprocessor/issues/1028

@network
Feature: non-feature specs
  Scenario: with messages enabled + reload-behavior
    Given additional preprocessor configuration
      """
      {
        "messages": {
          "enabled": true
        }
      }
      """
    And additional Cypress configuration
      """
      {
        "e2e": {
          "specPattern": "**/spec.js"
        }
      }
      """
    And a file named "cypress/e2e/spec.js" with:
      """
      it("should work", () => {
        cy.visit("https://duckduckgo.com/")
      })
      """
    When I run cypress
    Then it passes
