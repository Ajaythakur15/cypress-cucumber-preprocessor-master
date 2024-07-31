import { Then } from "@cucumber/cucumber";
import { JSDOM } from "jsdom";
import path from "path";
import { promises as fs } from "fs";
import assert from "assert";
import { findByText } from "@testing-library/dom";
import ICustomWorld from "../support/ICustomWorld";

Then("there should be a HTML report", async function (this: ICustomWorld) {
  await assert.doesNotReject(
    () => fs.access(path.join(this.tmpDir, "cucumber-report.html")),
    "Expected there to be a HTML file"
  );
});

Then(
  "the report should display when last run",
  async function (this: ICustomWorld) {
    const dom = await JSDOM.fromFile(
      path.join(this.tmpDir, "cucumber-report.html"),
      { runScripts: "dangerously" }
    );

    const dt = await findByText(
      dom.window.document.documentElement,
      "last run",
      {
        selector: "dt",
      }
    );

    const dd = await findByText(dt.parentElement!, /\d+ seconds? ago/, {
      selector: "dd",
    });

    assert(dd);
  }
);

Then(
  "the HTML should display {int} executed scenario(s)",
  async function (this: ICustomWorld, n: number) {
    const dom = await JSDOM.fromFile(
      path.join(this.tmpDir, "cucumber-report.html"),
      { runScripts: "dangerously" }
    );

    const dt = await findByText(
      dom.window.document.documentElement,
      /\d+ executed/,
      {
        selector: "dt",
      }
    );

    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const actual = parseInt(dt.textContent!, 10);

    assert.equal(actual, n);
  }
);

Then(
  "the HTML should display {int}% passed scenarios",
  async function (this: ICustomWorld, n: number) {
    const dom = await JSDOM.fromFile(
      path.join(this.tmpDir, "cucumber-report.html"),
      { runScripts: "dangerously" }
    );

    const dd = await findByText(
      dom.window.document.documentElement,
      /\d+% passed/,
      {
        selector: "dd",
      }
    );

    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const actual = parseInt(dd.textContent!, 10);

    assert.equal(actual, n);
  }
);

Then(
  "the report should have an image attachment",
  async function (this: ICustomWorld) {
    const dom = await JSDOM.fromFile(
      path.join(this.tmpDir, "cucumber-report.html"),
      { runScripts: "dangerously" }
    );

    const AccordionItemPanel = await findByText(
      dom.window.document.documentElement,
      (_, element) => element?.textContent?.includes("Attached Image") ?? false,
      { selector: '[data-accordion-component="AccordionItemPanel"]' }
    );

    assert(AccordionItemPanel);
  }
);

Then(
  "the HTML report should display {int} {string} scenario(s)",
  async function (this: ICustomWorld, n: number, status: string) {
    const dom = await JSDOM.fromFile(
      path.join(this.tmpDir, "cucumber-report.html"),
      { runScripts: "dangerously" }
    );

    const li = await findByText(
      dom.window.document.documentElement,
      new RegExp(`\\d+ ${status}`),
      {
        selector: "li",
      }
    );

    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const actual = parseInt(li.textContent!, 10);

    assert.equal(actual, n);
  }
);
