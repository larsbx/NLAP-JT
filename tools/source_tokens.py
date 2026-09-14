"""Small lexer helpers for source-only lexical audits.

The audits are policy guards, not parsers.  This masker deliberately preserves
line breaks and code characters while replacing comments and string literals
with spaces, so diagnostics retain their original line numbers.
"""

from __future__ import annotations


def mask_comments_and_strings(source: str) -> str:
    out: list[str] = []
    quote: str | None = None
    triple = False
    escaped = False
    index = 0

    while index < len(source):
        char = source[index]

        if quote is not None:
            if char == "\n":
                out.append("\n")
                if not triple:
                    quote = None
                    escaped = False
                index += 1
                continue
            if triple and source.startswith(quote * 3, index):
                out.extend("   ")
                index += 3
                quote = None
                triple = False
                continue
            out.append(" ")
            if not triple:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == quote:
                    quote = None
            index += 1
            continue

        if char == "#":
            newline = source.find("\n", index)
            if newline == -1:
                out.extend(" " * (len(source) - index))
                break
            out.extend(" " * (newline - index))
            index = newline
            continue

        if char in {"'", '"'}:
            triple = source.startswith(char * 3, index)
            quote = char
            width = 3 if triple else 1
            out.extend(" " * width)
            index += width
            continue

        out.append(char)
        index += 1

    return "".join(out)
