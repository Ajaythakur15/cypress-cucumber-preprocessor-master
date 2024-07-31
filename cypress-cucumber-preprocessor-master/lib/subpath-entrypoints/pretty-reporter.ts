import Mocha from "mocha";

export = class CucumberReporter extends Mocha.reporters.Base {
  constructor(runner: Mocha.Runner, options?: Mocha.MochaOptions) {
    super(runner, options);

    runner.once(Mocha.Runner.constants.EVENT_RUN_BEGIN, () => {
      console.log();
    });

    runner.once(Mocha.Runner.constants.EVENT_RUN_END, this.epilogue.bind(this));
  }
};
