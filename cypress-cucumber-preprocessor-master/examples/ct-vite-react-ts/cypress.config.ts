import { defineConfig } from "cypress";
import { devServer } from "@cypress/vite-dev-server";
import react from "@vitejs/plugin-react";
import { viteCommonjs } from "@originjs/vite-plugin-commonjs";
import { addCucumberPreprocessorPlugin } from "@badeball/cypress-cucumber-preprocessor";
import { createRollupPlugin } from "@badeball/cypress-cucumber-preprocessor/rollup";

export default defineConfig({
  component: {
    specPattern: "**/*.feature",
    devServer(devServerConfig) {
      return devServer({
        ...devServerConfig,
        framework: "react",
        viteConfig: {
          plugins: [
            react(),
            createRollupPlugin(devServerConfig.cypressConfig),
            viteCommonjs(),
          ],
        },
      });
    },
    async setupNodeEvents(on, config) {
      // This is required for the preprocessor to be able to generate JSON reports after each run, and more.
      await addCucumberPreprocessorPlugin(on, config);

      // Make sure to return the config object as it might have been modified by the plugin.
      return config;
    },
  },
});
