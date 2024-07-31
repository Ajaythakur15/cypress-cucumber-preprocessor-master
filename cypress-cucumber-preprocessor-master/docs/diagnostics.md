[← Back to documentation](readme.md)

# Diagnostics / dry run

A diagnostics utility is provided to verify that each step matches one, and only one, step definition. This can be run as shown below.

```
$ npx cypress-cucumber-diagnostics
```

This supports some of the same flags as Cypress, including

- `-P / --project` for specifying project directories aside from current working directory
- `-e / --env` for EG. specifying a different value for `stepDefinitions`

The intention here being that whatever flags you use to run `cypress run` can also be consumed by the executable to give appropriate diagnostics.

## Limitations

In order to obtain structured information about step definitions, these files are resolved and evaluated in a Node environment. This environment differs from the normal Cypress environment in that it's not a browser environment and Cypress globals are mocked and imitated to some degree.

This means that expressions such as that shown below will work.

```ts
import { Given } from "@badeball/cypress-cucumber-preprocessor";

const foo = Cypress.env("foo");

Given("a step", () => {
  if (foo) {
    // ...
  }
});
```

However, other may not. Cypress globals are mocked on a best-effort and need-to-have basis. If you're code doesn't run correctly during diagnostics, you may open up an issue on the tracker.
