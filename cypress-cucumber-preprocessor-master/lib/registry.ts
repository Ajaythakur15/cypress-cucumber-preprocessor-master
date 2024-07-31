import {
  CucumberExpression,
  RegularExpression,
  Expression,
  ParameterTypeRegistry,
  ParameterType,
} from "@cucumber/cucumber-expressions";

import parse from "@cucumber/tag-expressions";

import { IdGenerator } from "@cucumber/messages";

import { assertAndReturn } from "./helpers/assertions";

import DataTable from "./data_table";

import { CypressCucumberError } from "./helpers/error";

import {
  ICaseHookBody,
  ICaseHookOptions,
  ICaseHookParameter,
  IParameterTypeDefinition,
  IRunHookBody,
  IRunHookOptions,
  IStepDefinitionBody,
  IStepHookBody,
  IStepHookParameter,
} from "./public-member-types";

import {
  maybeRetrievePositionFromSourceMap,
  Position,
} from "./helpers/source-map";

export interface IStepDefinition<T extends unknown[], C extends Mocha.Context> {
  id: string;
  expression: Expression;
  implementation: IStepDefinitionBody<T, C>;
  position?: Position;
}

export class MissingDefinitionError extends CypressCucumberError {}

export class MultipleDefinitionsError extends CypressCucumberError {}

export type RunHookKeyword = "BeforeAll" | "AfterAll";

export type CaseHookKeyword = "Before" | "After";

export type StepHookKeyword = "BeforeStep" | "AfterStep";

type Node = ReturnType<typeof parse>;

export const DEFAULT_HOOK_ORDER = 10000;

export interface IRunHook {
  implementation: IRunHookBody;
  keyword: RunHookKeyword;
  order: number;
  position?: Position;
}

export interface ICaseHook {
  id: string;
  node: Node;
  implementation: ICaseHookBody;
  keyword: CaseHookKeyword;
  order: number;
  position?: Position;
  tags?: string;
  name?: string;
}

export interface IStepHook {
  node: Node;
  implementation: IStepHookBody;
  keyword: StepHookKeyword;
  order: number;
  position?: Position;
  tags?: string;
  name?: string;
}

const noopNode = { evaluate: () => true };

function parseMaybeTags(tags?: string): Node {
  return tags ? parse(tags) : noopNode;
}

export class Registry {
  public parameterTypeRegistry: ParameterTypeRegistry;

  private preliminaryStepDefinitions: {
    description: string | RegExp;
    implementation: () => void;
    position?: Position;
  }[] = [];

  public stepDefinitions: IStepDefinition<unknown[], Mocha.Context>[] = [];

  private preliminaryHooks: Omit<ICaseHook, "id">[] = [];

  public runHooks: IRunHook[] = [];

  public caseHooks: ICaseHook[] = [];

  public stepHooks: IStepHook[] = [];

  constructor(private experimentalSourceMap: boolean) {
    this.defineStep = this.defineStep.bind(this);
    this.runStepDefininition = this.runStepDefininition.bind(this);
    this.defineParameterType = this.defineParameterType.bind(this);
    this.defineBefore = this.defineBefore.bind(this);
    this.defineAfter = this.defineAfter.bind(this);

    this.parameterTypeRegistry = new ParameterTypeRegistry();
  }

  public finalize(newId: IdGenerator.NewId) {
    for (const { description, implementation, position } of this
      .preliminaryStepDefinitions) {
      if (typeof description === "string") {
        this.stepDefinitions.push({
          id: newId(),
          expression: new CucumberExpression(
            description,
            this.parameterTypeRegistry
          ),
          implementation,
          position,
        });
      } else {
        this.stepDefinitions.push({
          id: newId(),
          expression: new RegularExpression(
            description,
            this.parameterTypeRegistry
          ),
          implementation,
          position,
        });
      }
    }

    for (const preliminaryHook of this.preliminaryHooks) {
      this.caseHooks.push({
        id: newId(),
        ...preliminaryHook,
      });
    }
  }

  public defineStep(description: string | RegExp, implementation: () => void) {
    if (typeof description !== "string" && !(description instanceof RegExp)) {
      throw new Error("Unexpected argument for step definition");
    }

    this.preliminaryStepDefinitions.push({
      description,
      implementation,
      position: maybeRetrievePositionFromSourceMap(this.experimentalSourceMap),
    });
  }

  public defineParameterType<T, C extends Mocha.Context>({
    name,
    regexp,
    transformer,
  }: IParameterTypeDefinition<T, C>) {
    this.parameterTypeRegistry.defineParameterType(
      new ParameterType(name, regexp, null, transformer, true, false)
    );
  }

  public defineCaseHook(
    keyword: CaseHookKeyword,
    options: ICaseHookOptions,
    fn: ICaseHookBody
  ) {
    const { order, ...remainingOptions } = options;
    this.preliminaryHooks.push({
      node: parseMaybeTags(options.tags),
      implementation: fn,
      keyword: keyword,
      position: maybeRetrievePositionFromSourceMap(this.experimentalSourceMap),
      order: order ?? DEFAULT_HOOK_ORDER,
      ...remainingOptions,
    });
  }

  public defineBefore(options: ICaseHookOptions, fn: ICaseHookBody) {
    this.defineCaseHook("Before", options, fn);
  }

  public defineAfter(options: ICaseHookOptions, fn: ICaseHookBody) {
    this.defineCaseHook("After", options, fn);
  }

  public defineStepHook(
    keyword: StepHookKeyword,
    options: ICaseHookOptions,
    fn: IStepHookBody
  ) {
    const { order, ...remainingOptions } = options;
    this.stepHooks.push({
      node: parseMaybeTags(options.tags),
      implementation: fn,
      keyword: keyword,
      position: maybeRetrievePositionFromSourceMap(this.experimentalSourceMap),
      order: order ?? DEFAULT_HOOK_ORDER,
      ...remainingOptions,
    });
  }

  public defineBeforeStep(options: ICaseHookOptions, fn: IStepHookBody) {
    this.defineStepHook("BeforeStep", options, fn);
  }

  public defineAfterStep(options: ICaseHookOptions, fn: IStepHookBody) {
    this.defineStepHook("AfterStep", options, fn);
  }

  public defineRunHook(
    keyword: RunHookKeyword,
    options: IRunHookOptions,
    fn: IRunHookBody
  ) {
    this.runHooks.push({
      implementation: fn,
      keyword: keyword,
      position: maybeRetrievePositionFromSourceMap(this.experimentalSourceMap),
      order: options.order ?? DEFAULT_HOOK_ORDER,
    });
  }

  public defineBeforeAll(options: IRunHookOptions, fn: IRunHookBody) {
    this.defineRunHook("BeforeAll", options, fn);
  }

  public defineAfterAll(options: IRunHookOptions, fn: IRunHookBody) {
    this.defineRunHook("AfterAll", options, fn);
  }

  public getMatchingStepDefinitions(text: string) {
    return this.stepDefinitions.filter((stepDefinition) =>
      stepDefinition.expression.match(text)
    );
  }

  public resolveStepDefintion(text: string) {
    const matchingStepDefinitions = this.getMatchingStepDefinitions(text);

    if (matchingStepDefinitions.length === 0) {
      throw new MissingDefinitionError(
        `Step implementation missing for: ${text}`
      );
    } else if (matchingStepDefinitions.length > 1) {
      throw new MultipleDefinitionsError(
        `Multiple matching step definitions for: ${text}\n` +
          matchingStepDefinitions
            .map((stepDefinition) => {
              const { expression } = stepDefinition;

              const stringExpression =
                expression instanceof RegularExpression
                  ? String(expression.regexp)
                  : expression.source;

              if (stepDefinition.position) {
                return ` ${stringExpression} - ${stepDefinition.position.source}:${stepDefinition.position.line}`;
              } else {
                return ` ${stringExpression}`;
              }
            })
            .join("\n")
      );
    } else {
      return matchingStepDefinitions[0];
    }
  }

  public runStepDefininition(
    world: Mocha.Context,
    text: string,
    argument?: DataTable | string
  ): unknown {
    const stepDefinition = this.resolveStepDefintion(text);

    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const args = stepDefinition.expression
      .match(text)!
      .map((match) => match.getValue(world));

    if (argument) {
      args.push(argument);
    }

    return stepDefinition.implementation.apply(world, args);
  }

  public resolveCaseHooks(keyword: CaseHookKeyword, tags: string[]) {
    return this.caseHooks
      .filter((hook) => hook.keyword === keyword && hook.node.evaluate(tags))
      .sort((a, b) => {
        return a.order - b.order;
      });
  }

  public resolveBeforeHooks(tags: string[]) {
    return this.resolveCaseHooks("Before", tags);
  }

  public resolveAfterHooks(tags: string[]) {
    return this.resolveCaseHooks("After", tags).reverse();
  }

  public runCaseHook(
    world: Mocha.Context,
    hook: ICaseHook,
    options: ICaseHookParameter
  ) {
    return hook.implementation.call(world, options);
  }

  public resolveStepHooks(keyword: StepHookKeyword, tags: string[]) {
    return this.stepHooks
      .filter((hook) => hook.keyword === keyword && hook.node.evaluate(tags))
      .sort((a, b) => {
        return a.order - b.order;
      });
  }

  public resolveBeforeStepHooks(tags: string[]) {
    return this.resolveStepHooks("BeforeStep", tags);
  }

  public resolveAfterStepHooks(tags: string[]) {
    return this.resolveStepHooks("AfterStep", tags).reverse();
  }

  public runStepHook(
    world: Mocha.Context,
    hook: IStepHook,
    options: IStepHookParameter
  ) {
    return hook.implementation.call(world, options);
  }

  public resolveRunHooks(keyword: RunHookKeyword) {
    return this.runHooks
      .filter((hook) => hook.keyword === keyword)
      .sort((a, b) => {
        return a.order - b.order;
      });
  }

  public resolveBeforeAllHooks() {
    return this.resolveRunHooks("BeforeAll");
  }

  public resolveAfterAllHooks() {
    return this.resolveRunHooks("AfterAll").reverse();
  }

  public runRunHook(world: Mocha.Context, hook: IRunHook) {
    return hook.implementation.call(world);
  }
}

const globalPropertyName =
  "__cypress_cucumber_preprocessor_registry_dont_use_this";

export function withRegistry(
  experimentalSourceMap: boolean,
  fn: () => void
): Registry {
  const registry = new Registry(experimentalSourceMap);
  assignRegistry(registry);
  fn();
  freeRegistry();
  return registry;
}

export function assignRegistry(registry: Registry) {
  globalThis[globalPropertyName] = registry;
}

export function freeRegistry() {
  delete globalThis[globalPropertyName];
}

export function getRegistry(): Registry {
  return assertAndReturn(
    globalThis[globalPropertyName],
    "Expected to find a global registry (this usually means you are trying to define steps or hooks in support/e2e.js, which is not supported)"
  );
}
