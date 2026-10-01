"""Add Living Board strings to lib/l10n/app_en.arb and regenerate l10n.

    python tools/lb_add_strings.py path/to/strings.json

strings.json:
    {
      "lbDailyEmpty": ["ALL FED. COME BACK TOMORROW.", "Shown when every challenge is claimed"],
      "lbRanksRow":   ["#{rank} · {name}", "Leaderboard row", {"rank": "String", "name": "String"}],
      "lbRuns":       ["{n, plural, =1{1 run} other{{n} runs}}", "Run count", {"n": "int"}]
    }

Placeholders default to String (pass locale-formatted numbers); give an
explicit map for ints (plurals). Existing keys are overwritten. Safe to run
from several processes at once: an exclusive lock directory serialises the
merge and the gen-l10n run.
"""
import collections
import json
import os
import re
import subprocess
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ARB = os.path.join(ROOT, "lib", "l10n", "app_en.arb")
LOCK = os.path.join(ROOT, ".dart_tool", "lb_strings.lock")


def placeholders(value):
    names, depth = [], 0
    for i, c in enumerate(value):
        if c == "{":
            if depth == 0:
                m = re.match(r"\{(\w+)", value[i:])
                if m and m.group(1) not in names:
                    names.append(m.group(1))
            depth += 1
        elif c == "}":
            depth -= 1
    return names


def main(path):
    with open(path, encoding="utf-8") as f:
        entries = json.load(f)
    os.makedirs(os.path.dirname(LOCK), exist_ok=True)
    for _ in range(600):
        try:
            os.mkdir(LOCK)
            break
        except FileExistsError:
            time.sleep(0.5)
    else:
        sys.exit("could not acquire " + LOCK)
    try:
        with open(ARB, encoding="utf-8") as f:
            arb = json.load(f, object_pairs_hook=collections.OrderedDict)
        for key, spec in entries.items():
            value, desc = spec[0], spec[1]
            types = spec[2] if len(spec) > 2 else {}
            arb[key] = value
            meta = {"description": desc}
            ph = placeholders(value)
            if ph:
                meta["placeholders"] = {n: {"type": types.get(n, "String")} for n in ph}
            arb["@" + key] = meta
        with open(ARB, "w", encoding="utf-8", newline="\n") as f:
            json.dump(arb, f, ensure_ascii=False, indent=2)
            f.write("\n")
        r = subprocess.run("flutter gen-l10n", cwd=ROOT, shell=True, capture_output=True, text=True)
        out = (r.stdout + r.stderr).strip()
        if r.returncode != 0:
            print(out)
            sys.exit(r.returncode)
        print(f"added {len(entries)} strings")
    finally:
        os.rmdir(LOCK)


if __name__ == "__main__":
    main(sys.argv[1])
