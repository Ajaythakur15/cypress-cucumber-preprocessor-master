import { After, Before, formatterHelpers } from "@cucumber/cucumber";
import assert from "assert";
import { promises as fs } from "fs";
import path from "path";
import { isPre12, writeFile } from "./helpers";

const projectPath = path.join(__dirname, "..", "..");

Before(async function ({ gherkinDocument, pickle }) {
  assert(gherkinDocument.uri, "Expected gherkinDocument.uri to be present");

  const relativeUri = path.relative(process.cwd(), gherkinDocument.uri);

  const { line } = formatterHelpers.PickleParser.getPickleLocation({
    gherkinDocument,
    pickle,
  });

  this.tmpDir = path.join(projectPath, "tmp", `${relativeUri}_${line}`);

  await fs.rm(this.tmpDir, { recursive: true, force: true });

  await writeFile(
    path.join(this.tmpDir, "cypress", "support", "e2e.js"),
    `
      Cypress.Commands.add("expectCommandLogEntry", ({ method, message }) => {
        const selector = \`.command-info:has(> .command-method:contains('\${method}')) .command-message-text:contains('\${message}')\`;
        cy.then(() => {}).should(() => {
          expect(Cypress.$(top.document).find(selector)).to.exist;
        });
      });
    `
  );

  await writeFile(
    path.join(this.tmpDir, "cypress.config.js"),
    `
        const { defineConfig } = require("cypress");
        const setupNodeEvents = require("./setupNodeEvents.js");
  
        module.exports = defineConfig({
          e2e: {
            specPattern: "cypress/e2e/**/*.feature",
            video: false,
            setupNodeEvents
          }
        })
      `
  );

  await fs.mkdir(path.join(this.tmpDir, "node_modules", "@badeball"), {
    recursive: true,
  });

  await fs.symlink(
    projectPath,
    path.join(
      this.tmpDir,
      "node_modules",
      "@badeball",
      "cypress-cucumber-preprocessor"
    ),
    "dir"
  );
});

Before({ tags: "not @no-default-preprocessor-config" }, async function () {
  await writeFile(
    path.join(this.tmpDir, ".cypress-cucumber-preprocessorrc"),
    "{}"
  );
});

Before({ tags: "not @no-default-plugin" }, async function () {
  await writeFile(
    path.join(this.tmpDir, "setupNodeEvents.js"),
    `
        const { addCucumberPreprocessorPlugin } = require("@badeball/cypress-cucumber-preprocessor");
        const { createEsbuildPlugin } = require("@badeball/cypress-cucumber-preprocessor/esbuild");
        const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");

        module.exports = async function setupNodeEvents(on, config) {
          await addCucumberPreprocessorPlugin(on, config);

          on(
            "file:preprocessor",
            createBundler({
              plugins: [createEsbuildPlugin(config)],
            })
          );

          return config;
        };
      `
  );
});

Before({ tags: "@cypress>=12" }, async function () {
  if (isPre12()) {
    return "skipped";
  }
});

After(function () {
  if (
    this.lastRun != null &&
    this.lastRun.exitCode !== 0 &&
    !this.verifiedLastRunError
  ) {
    throw new Error(
      `Last run errored unexpectedly. Output:\n\n${this.lastRun.output}`
    );
  }
});
