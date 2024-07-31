Feature: hooks ordering

  Hooks should be executed in the following order:
   - before
   - BeforeAll
   - beforeEach
   - Before
   - Background steps
   - BeforeStep
   - Ordinary steps
   - AfterStep (in reverse order)
   - After
   - afterEach
   - AfterAll
   - after

  Hooks with user-defined ordering should run in the correct order

  Scenario: with all hooks incrementing a counter
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Background:
          Given a background step
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        Before,
        After,
        BeforeStep,
        AfterStep,
        BeforeAll,
        AfterAll
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      BeforeAll(() => {
        expect(counter++, "Expect BeforeAll() to be called after before()").to.equal(0)
      })
      beforeEach(function() {
        expect(counter++, "Expected beforeEach() to be called after before()").to.equal(1)
      })
      Before(function() {
        expect(counter++, "Expected Before() to be called after beforeEach()").to.equal(2)
      })
      Given("a background step", function() {
        expect(counter++, "Expected a background step to be called after Before()").to.equal(3)
      })
      BeforeStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected BeforeStep() to be called before ordinary steps").to.equal(4)
        }
      })
      Given("an ordinary step", function() {
        expect(counter++, "Expected an ordinary step to be called after a background step").to.equal(5)
      })
      AfterStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected AfterStep() to be called after ordinary steps").to.equal(7)
        }
      })
      AfterStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected AfterStep() to be called after ordinary steps").to.equal(6)
        }
      })
      After(function() {
        expect(counter++, "Expected After() to be called in reverse order of definition").to.equal(9)
      })
      After(function() {
        expect(counter++, "Expected After() to be called after ordinary steps").to.equal(8)
      })
      afterEach(function() {
        expect(counter++, "Expected afterEach() to be called after After()").to.equal(10)
      })
      AfterAll(function() {
        expect(counter++, "Expected AfterAll() to be called after afterEach()").to.equal(11)
      })
      after(function() {
        expect(counter++, "Expected after() to be called after AfterAll()").to.equal(12)
      })
      """
    When I run cypress
    Then it passes

  Scenario Outline: two <hook-type> hooks, last with order: <order-option>
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("an ordinary step", function() {});
      """
    And two "<hook-type>" hooks, last with order: "<order-option>", asserting "<expected-order>" execution
    When I run cypress
    Then it passes

      Examples:
      | hook-type  | order-option | expected-order |
      | Before     | undefined    | in-order       |
      | Before     | 10000        | in-order       |
      | Before     | 9999         | reversed       |
      | After      | undefined    | in-order       |
      | After      | 10000        | in-order       |
      | After      | 9999         | reversed       |
      | BeforeAll  | undefined    | in-order       |
      | BeforeAll  | 10000        | in-order       |
      | BeforeAll  | 9999         | reversed       |
      | AfterAll   | undefined    | in-order       |
      | AfterAll   | 10000        | in-order       |
      | AfterAll   | 9999         | reversed       |
      | BeforeStep | undefined    | in-order       |
      | BeforeStep | 10000        | in-order       |
      | BeforeStep | 9999         | reversed       |
      | AfterStep  | undefined    | in-order       |
      | AfterStep  | 10000        | in-order       |
      | AfterStep  | 9999         | reversed       |
