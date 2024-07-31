export function minIndent(content: string) {
  const match = content.match(/^[ \t]*(?=\S)/gm);

  if (!match) {
    return 0;
  }

  return match.reduce((r, a) => Math.min(r, a.length), Infinity);
}

export function stripIndent(content: string) {
  const indent = minIndent(content);

  if (indent === 0) {
    return content;
  }

  const regex = new RegExp(`^[ \\t]{${indent}}`, "gm");

  return content.replace(regex, "");
}

export function indent(
  string: string,
  options: { count?: number; indent?: string; includeEmptyLines?: boolean } = {}
) {
  const { count = 1, indent = " ", includeEmptyLines = false } = options;

  if (count === 0) {
    return string;
  }

  const regex = includeEmptyLines ? /^/gm : /^(?!\s*$)/gm;

  return string.replace(regex, indent.repeat(count));
}
