#!/usr/bin/env python3
"""
build_tools.py -- turn the cell-manifest .wl files into

  (a) a runnable .wls script containing only the Input cells, in order, and
  (b) a Wolfram .nb notebook containing every cell with its style.

The manifest format is one marker line per cell,

      (* ::Title:: *)      (* ::Section:: *)      (* ::Subsection:: *)
      (* ::Text:: *)       (* ::Input:: *)

followed by the cell body until the next marker.  Bodies of Text/Title/Section cells are
literal text; bodies of Input cells are Wolfram Language code.
"""

import re
import sys
import glob
import os

MARKER = re.compile(r'^\(\*\s*::\s*([A-Za-z][A-Za-z0-9-]*)\s*::\s*(.*?)\*\)\s*$')

KNOWN_STYLES = {
    "Title": "Title",
    "Subtitle": "Subtitle",
    "Section": "Section",
    "Subsection": "Subsection",
    "Subsubsection": "Subsubsection",
    "Text": "Text",
    "Input": "Input",
    "Item": "Item",
}


def parse_manifest(paths):
    """Return a list of (style, body) pairs, in file order then line order."""
    cells = []
    for path in paths:
        with open(path, "r", encoding="utf-8") as fh:
            lines = fh.read().split("\n")
        style = None
        buf = []
        for line in lines:
            m = MARKER.match(line)
            if m:
                name = m.group(1)
                if style is not None:
                    cells.append((style, "\n".join(buf).strip("\n")))
                buf = []
                style = KNOWN_STYLES.get(name)  # None for unknown markers -> skipped
            else:
                if style is not None:
                    buf.append(line)
        if style is not None:
            cells.append((style, "\n".join(buf).strip("\n")))
    # drop cells whose body is entirely blank
    return [(s, b) for (s, b) in cells if b.strip() != ""]


def wl_string(s):
    """Encode a Python str as a Wolfram Language double-quoted string literal."""
    out = []
    for ch in s:
        if ch == "\\":
            out.append("\\\\")
        elif ch == '"':
            out.append('\\"')
        elif ch == "\n":
            out.append("\\n")
        elif ch == "\r":
            continue
        elif ch == "\t":
            out.append("\\t")
        else:
            out.append(ch)
    return '"' + "".join(out) + '"'


def build_script(cells, out_path, header=""):
    """Write a .wls that evaluates every Input cell in order."""
    with open(out_path, "w", encoding="utf-8") as fh:
        if header:
            fh.write(header.rstrip() + "\n\n")
        n = 0
        for style, body in cells:
            if style != "Input":
                continue
            n += 1
            fh.write("\n(* ---------- Input cell %d ---------- *)\n" % n)
            fh.write("cfRunCell[%d, Hold[\n" % n)
            fh.write(body.rstrip() + "\n")
            fh.write("]];\n")
        fh.write("\ncfRunSummary[];\n")
    return n


def build_notebook(cells, out_path, window_title):
    """Write a .nb file as a plain-text Wolfram expression."""
    parts = []
    for style, body in cells:
        if style == "Input":
            parts.append("Cell[BoxData[%s], \"Input\"]" % wl_string(body))
        else:
            parts.append("Cell[%s, %s]" % (wl_string(body), wl_string(style)))
    with open(out_path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("(* Content-type: application/vnd.wolfram.mathematica *)\n\n")
        fh.write("(*** Wolfram Notebook File ***)\n")
        fh.write("(* http://www.wolfram.com/nb *)\n\n")
        fh.write("(* CreatedBy='claude-fable build_tools.py' *)\n\n")
        fh.write("Notebook[{\n")
        fh.write(",\n".join(parts))
        fh.write("\n},\n")
        fh.write("WindowSize->{1400, 900},\n")
        fh.write("WindowTitle->%s,\n" % wl_string(window_title))
        fh.write("WindowMargins->{{Automatic, 0}, {Automatic, 0}},\n")
        fh.write("FrontEndVersion->\"14.0 for Microsoft Windows (64-bit)\",\n")
        fh.write("StyleDefinitions->\"Default.nb\"\n")
        fh.write("]\n")
    return len(cells)


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    paths = sorted(glob.glob(os.path.join(here, "cells_part*.wl")))
    if not paths:
        print("no cells_part*.wl found in", here)
        return 1
    cells = parse_manifest(paths)
    counts = {}
    for s, _ in cells:
        counts[s] = counts.get(s, 0) + 1
    print("manifest files :", [os.path.basename(p) for p in paths])
    print("cells parsed   :", len(cells), counts)

    runner_header = open(os.path.join(here, "runner_header.wl"), "r", encoding="utf-8").read()
    n_in = build_script(cells, os.path.join(here, "run_all.wls"), runner_header)
    print("run_all.wls    :", n_in, "Input cells")

    nb = os.path.join(here, "claude-fable_Einstein-Rosen-2-Planes.nb")
    n_nb = build_notebook(cells, nb, "claude-fable_Einstein-Rosen-2-Planes")
    print("notebook       :", n_nb, "cells ->", nb)
    return 0


if __name__ == "__main__":
    sys.exit(main())
