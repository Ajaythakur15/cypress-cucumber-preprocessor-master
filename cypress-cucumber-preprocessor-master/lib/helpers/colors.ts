import chalk from "chalk";

/**
 * Copied from Cypress [1] as this isn't exposed.
 *
 * [1] https://github.com/cypress-io/cypress/blob/v12.13.0/cli/lib/util.js#L348-L363
 */
export function useColors() {
  // if we've been explictly told not to support
  // color then turn this off
  if (process.env.NO_COLOR) {
    return false;
  }

  // https://github.com/cypress-io/cypress/issues/1747
  // always return true in CI providers
  if (process.env.CI) {
    return true;
  }

  // ensure that both stdout and stderr support color
  return Boolean(chalk.supportsColor) && Boolean(chalk.stderr.supportsColor);
}
