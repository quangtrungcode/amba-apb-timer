import re
import sys
from pathlib import Path

LOG_DIR = Path("log")
COV_FILE = Path("coverage/summary_report.txt")

SUMMARY_RE = re.compile(r"\[TEST SUMMARY\]\s+PATTERN:\s*(\w+)\s*--->\s*(\w+)")
ERRORS_RE = re.compile(r"Errors:\s*(\d+),\s*Warnings:\s*(\d+)")
INST_RE = re.compile(r"=== Instance:\s*(\S+)")
COV_RE = re.compile(r"^\s*([A-Za-z][A-Za-z ]*?)\s+(\d+)\s+(\d+)\s+(\d+)\s+([\d.]+)%")


def parse_log(path):
    name, result = path.stem, "NO_RESULT"
    errors = warnings = "N/A"
    with open(path, encoding="utf-8", errors="ignore") as f:
        for line in f:
            m = SUMMARY_RE.search(line)
            if m:
                name, result = m.group(1), m.group(2)
            m = ERRORS_RE.search(line)
            if m:
                errors, warnings = int(m.group(1)), int(m.group(2))
    return name, result, errors, warnings


def parse_coverage(path):
    data = {}
    inst = None
    with open(path, encoding="utf-8", errors="ignore") as f:
        for line in f:
            m = INST_RE.search(line)
            if m:
                current_inst = m.group(1)
                if current_inst.startswith("/test_bench/dut"):
                    inst = current_inst
                    data[inst] = {}
                else:
                    inst = None  
                continue
            
            m = COV_RE.match(line)
            if m and inst:
                data[inst][m.group(1)] = (int(m.group(2)), int(m.group(3)))
    return data


def print_tests(rows):
    print(f"{'TEST':<28}{'RESULT':<12}{'ERR':>5}{'WARN':>6}")
    print("-" * 51)
    for name, result, err, warn in rows:
        print(f"{name:<28}{result:<12}{str(err):>5}{str(warn):>6}")
    passed = sum(1 for r in rows if r[1] == "PASSED")
    print("-" * 51)
    print(f"Total: {len(rows)}   Passed: {passed}   Failed: {len(rows) - passed}")
    return passed == len(rows)


def print_coverage(data):
    total = {}
    for inst, metrics in data.items():
        for metric, (bins, hits) in metrics.items():
            b, h = total.get(metric, (0, 0))
            total[metric] = (b + bins, h + hits)
    print(f"\n{'COVERAGE':<14}{'HITS/BINS':>12}{'PERCENT':>10}")
    print("-" * 36)
    for metric, (b, h) in total.items():
        print(f"{metric:<14}{f'{h}/{b}':>12}{100 * h / b:>9.2f}%")
    for inst, metrics in data.items():
        for metric, (bins, hits) in metrics.items():
            if hits < bins:
                print(f"  ! {inst}: {metric} {hits}/{bins}")


def main():
    logs = sorted(LOG_DIR.glob("*.log"))
    if not logs:
        print(f"No log files found in {LOG_DIR}/")
        return 1
    ok = print_tests([parse_log(p) for p in logs])
    if COV_FILE.exists():
        print_coverage(parse_coverage(COV_FILE))
    else:
        print(f"\n(coverage file not found: {COV_FILE})")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
