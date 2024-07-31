export function memoize<T extends (...args: any[]) => any>(
  fn: T
): (...args: Parameters<T>) => ReturnType<T> {
  let result: ReturnType<T>;

  return (...args: Parameters<T>) => {
    if (result) {
      return result;
    }

    return (result = fn(...args));
  };
}
