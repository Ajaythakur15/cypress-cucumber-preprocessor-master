import path from "path";

import * as glob from "glob";

import util from "util";

import assert from "assert";

import isPathInside from "is-path-inside";

import { ICypressConfiguration } from "@badeball/cypress-configuration";

import debug from "./helpers/debug";

import { IPreprocessorConfiguration } from "./preprocessor-configuration";

import { ensureIsAbsolute } from "./helpers/paths";

export async function getStepDefinitionPaths(
  stepDefinitionPatterns: string[]
): Promise<string[]> {
  return (
    await Promise.all(
      stepDefinitionPatterns.map((pattern) =>
        glob.glob(pattern, { nodir: true, windowsPathsNoEscape: true })
      )
    )
  ).reduce((acum, el) => acum.concat(el), []);
}

function trimFeatureExtension(filepath: string) {
  return filepath.replace(/\.feature$/, "");
}

export function pathParts(relativePath: string): string[] {
  assert(
    !path.isAbsolute(relativePath),
    `Expected a relative path but got ${relativePath}`
  );

  const parts: string[] = [];

  do {
    parts.push(relativePath);
  } while (
    (relativePath = path.normalize(path.join(relativePath, ".."))) !== "."
  );

  return parts;
}

export function getStepDefinitionPatterns(
  configuration: {
    cypress: Pick<ICypressConfiguration, "projectRoot">;
    preprocessor: Pick<
      IPreprocessorConfiguration,
      "stepDefinitions" | "implicitIntegrationFolder"
    >;
  },
  filepath: string
): string[] {
  const projectRoot = configuration.cypress.projectRoot;

  if (!isPathInside(filepath, projectRoot)) {
    throw new Error(`${filepath} is not inside ${projectRoot}`);
  }

  const filepathReplacement = glob.escape(
    trimFeatureExtension(
      path.relative(
        configuration.preprocessor.implicitIntegrationFolder,
        filepath
      )
    ),
    { windowsPathsNoEscape: true }
  );

  debug(`replacing [filepath] with ${util.inspect(filepathReplacement)}`);

  const parts = pathParts(filepathReplacement);

  debug(`replacing [filepart] with ${util.inspect(parts)}`);

  const stepDefinitions = [configuration.preprocessor.stepDefinitions].flat();

  return stepDefinitions
    .flatMap((pattern) => {
      if (pattern.includes("[filepath]") && pattern.includes("[filepart]")) {
        throw new Error(
          `Pattern cannot contain both [filepath] and [filepart], but got ${util.inspect(
            pattern
          )}`
        );
      } else if (pattern.includes("[filepath]")) {
        return pattern.replace("[filepath]", filepathReplacement);
      } else if (pattern.includes("[filepart]")) {
        return [
          ...parts.map((part) => pattern.replace("[filepart]", part)),
          path.normalize(pattern.replace("[filepart]", ".")),
        ];
      } else {
        return pattern;
      }
    })
    .map((pattern) => ensureIsAbsolute(projectRoot, pattern));
}
