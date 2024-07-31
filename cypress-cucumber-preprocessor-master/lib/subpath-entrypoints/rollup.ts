import { Plugin } from "rollup";

import { ICypressConfiguration } from "@badeball/cypress-configuration";

import { compile } from "../template";

export function createRollupPlugin(config: ICypressConfiguration): Plugin {
  return {
    name: "transform-feature",
    async transform(src: string, id: string) {
      if (/\.feature$/.test(id)) {
        return {
          code: await compile(config, src, id),
          map: null,
        };
      }
    },
  };
}

export default createRollupPlugin;
