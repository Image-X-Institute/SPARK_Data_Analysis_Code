import re
import sys

def extract_strings(filepath, min_length=8):
    """Extract meaningful text strings from a binary file."""
    with open(filepath, "rb") as f:
        data = f.read()

    # Find runs of printable ASCII characters above minimum length
    pattern = rb'[ -~]{' + str(min_length).encode() + rb',}'
    matches = re.finditer(pattern, data)

    results = []
    for m in matches:
        s = m.group(0).decode('latin-1').strip()
        # Keep only strings that contain at least 2 letters — filters out
        # binary noise that happens to fall in printable ASCII range
        if sum(c.isalpha() for c in s) >= 2:
            results.append((m.start(), s))
    return results


def inspect(filepath):
    print(f"File: {filepath}\n")
    print("── TEXT STRINGS FOUND IN FILE ──\n")
    strings = extract_strings(filepath)
    for offset, s in strings:
        print(f"  [offset {offset:08d}]  {s}")
    print(f"\n── TOTAL: {len(strings)} strings found ──")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        filepath = input("Enter path to .bin file: ").strip().strip('"')
    else:
        filepath = sys.argv[1]
    inspect(filepath)
