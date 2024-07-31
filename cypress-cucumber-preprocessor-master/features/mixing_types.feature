Feature: mixing feature and non-feature specs: API
  Background:
    Given additional Cypress configuration
      """
      {
        "e2e": {
          "specPattern": "**/*.{spec.js,feature}"
        }
      }
      """

  Scenario: feature
    Given a file named "cypress/e2e/a.feature" with:
      """
      @foo
      Feature: a feature name
        Scenario: a scenario name
          Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { When, isFeature, doesFeatureMatch } = require("@badeball/cypress-cucumber-preprocessor");
      When("a step", function() {
        expect(isFeature()).to.be.true;
        expect(doesFeatureMatch("@foo")).to.be.true;
      });
      """
    And a file named "cypress/support/e2e.js" with:
      """
      const { isFeature, doesFeatureMatch } = require("@badeball/cypress-cucumber-preprocessor");
      beforeEach(() => {
        expect(isFeature()).to.be.true;
        expect(doesFeatureMatch("@foo")).to.be.true;
      });
      """
    When I run cypress
    Then it passes

  Scenario: non-feature
    Given a file named "cypress/e2e/a.spec.js" with:
      """
      const { isFeature, doesFeatureMatch } = require("@badeball/cypress-cucumber-preprocessor");
      it("should work", () => {
        expect(isFeature()).to.be.false;
        expect(doesFeatureMatch).to.throw("Expected to find internal properties, but didn't. This is likely because you're calling doesFeatureMatch() in a non-feature spec. Use doesFeatureMatch() in combination with isFeature() if you have both feature and non-feature specs");
      });
      """
    And a file named "cypress/support/e2e.js" with:
      """
      const { isFeature, doesFeatureMatch } = require("@badeball/cypress-cucumber-preprocessor");
      beforeEach(() => {
        expect(isFeature()).to.be.false;
        expect(doesFeatureMatch).to.throw("Expected to find internal properties, but didn't. This is likely because you're calling doesFeatureMatch() in a non-feature spec. Use doesFeatureMatch() in combination with isFeature() if you have both feature and non-feature specs");
      });
      """
    When I run cypress
    Then it passes
