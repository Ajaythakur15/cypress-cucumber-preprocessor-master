import { Registry, assignRegistry, freeRegistry } from "../registry";

const registry = new Registry(false);

assignRegistry(registry);

export function getAndFreeRegistry() {
  freeRegistry();
  return registry;
}
