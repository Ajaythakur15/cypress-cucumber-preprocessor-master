import { Given, Then } from "@badeball/cypress-cucumber-preprocessor";

import { mount } from "cypress/react18"

import App from "../../src/App";

Given("I render the component", () => {
  mount(<App />);
});

Then("I should see the text {string}", (text: string) => {
  cy.contains(text).should("exist");
});
