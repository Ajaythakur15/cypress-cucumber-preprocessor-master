import { Given } from "@cucumber/cucumber";
import stripIndent from "strip-indent";
import path from "path";
import { writeFile } from "../support/helpers";
import ICustomWorld from "../support/ICustomWorld";

Given(
  "a file named {string} with:",
  async function (this: ICustomWorld, filePath, fileContent) {
    const absoluteFilePath = path.join(this.tmpDir, filePath);

    await writeFile(absoluteFilePath, stripIndent(fileContent));
  }
);

Given(
  "an empty file named {string}",
  async function (this: ICustomWorld, filePath) {
    const absoluteFilePath = path.join(this.tmpDir, filePath);

    await writeFile(absoluteFilePath, "");
  }
);
