export type StrictTimestamp = {
  seconds: number;
  nanos: number;
};

export function createTimestamp(): StrictTimestamp {
  const now = new Date().getTime();

  const seconds = Math.floor(now / 1_000);

  const nanos = (now - seconds * 1_000) * 1_000_000;

  return {
    seconds,
    nanos,
  };
}

export function duration(
  start: StrictTimestamp,
  end: StrictTimestamp
): StrictTimestamp {
  return {
    seconds: end.seconds - start.seconds,
    nanos: end.nanos - start.nanos,
  };
}

export function durationToNanoseconds(duration: StrictTimestamp): number {
  return Math.floor(duration.seconds * 1_000_000_000 + duration.nanos);
}
