import messages from "@cucumber/messages";

export const TASK_SPEC_ENVELOPES =
  "cypress-cucumber-preprocessor:spec-envelopes";

export interface ITaskSpecEnvelopes {
  messages: messages.Envelope[];
}

export const TASK_TEST_CASE_STARTED =
  "cypress-cucumber-preprocessor:test-case-started";

export type ITaskTestCaseStarted = messages.TestCaseStarted;

export const TASK_TEST_CASE_FINISHED =
  "cypress-cucumber-preprocessor:test-case-finished";

export type ITaskTestCaseFinished = messages.TestCaseFinished;

export const TASK_TEST_STEP_STARTED =
  "cypress-cucumber-preprocessor:test-step-started";

export type ITaskTestStepStarted = messages.TestStepStarted;

export const TASK_TEST_STEP_FINISHED =
  "cypress-cucumber-preprocessor:test-step-finished";

export type ITaskTestStepFinished = messages.TestStepFinished;

export const TASK_CREATE_STRING_ATTACHMENT =
  "cypress-cucumber-preprocessor:create-string-attachment";

export interface ITaskCreateStringAttachment {
  data: string;
  mediaType: string;
  encoding: messages.AttachmentContentEncoding;
}
