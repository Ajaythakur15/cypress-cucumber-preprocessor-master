#!/usr/bin/env node

import { mergeMessagesArgs } from "../helpers/merge";

mergeMessagesArgs(process).catch((err) => {
  console.error(err.stack);
  process.exitCode = 1;
});
