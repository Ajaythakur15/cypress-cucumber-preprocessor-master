export const homepage =
  "https://github.com/badeball/cypress-cucumber-preprocessor";

export class CypressCucumberError extends Error {}

export function createError(message: string) {
  return new CypressCucumberError(
    `${message} (this might be a bug, please report at ${homepage})`
  );
}
