export interface ExtraOptions {
  extraArgs?: string[];
  extraEnv?: Record<string, string>;
  expectedExitCode?: number;
}

export default interface ICustomWorld {
  tmpDir: string;
  verifiedLastRunError: boolean | undefined;
  lastRun:
    | {
        stdout: string;
        stderr: string;
        output: string;
        exitCode: number;
      }
    | undefined;

  runCypress(options?: ExtraOptions): Promise<void>;

  runDiagnostics(options?: ExtraOptions): Promise<void>;

  runMergeMessages(options?: ExtraOptions): Promise<void>;
}
