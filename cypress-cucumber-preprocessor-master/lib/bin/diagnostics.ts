#!/usr/bin/env node

import { execute } from "../diagnostics";

execute({ argv: process.argv, env: process.env, cwd: process.cwd() }).catch(
  (err) => {
    console.error(err.stack);
    process.exitCode = 1;
  }
);
