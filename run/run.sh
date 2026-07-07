#!/bin/bash
# Shared Memory UVM — Xcelium run script
#
# Usage:
#   ./sim/run.sh                      # test_sanity_fac (default, no GUI)
#   ./sim/run.sh wifi                 # test_wifi_split
#   ./sim/run.sh bt                   # test_bt_split
#   ./sim/run.sh coverage             # test_coverage_regression (all IFs, one sim)
#   ./sim/run.sh all                  # regression (sanity + wifi + bt)
#   ./sim/run.sh cov-all              # full coverage regression + summary log
#   ./sim/run.sh --imc coverage       # collect functional cov for IMC
#   ./sim/run_coverage.sh --clean     # regression + IMC database (cov_work/)
#   ./sim/run_imc.sh                  # open IMC GUI on cov_work/
#   ./sim/run_imc.sh --report         # text report without GUI
#   ./sim/run_gui.sh sanity           # SimVision waves (single test only)
#   ./sim/run_coverage.sh             # shortcut for ./sim/run.sh --imc cov-all
#
# Run from project root (shared_memory_verification/) or anywhere.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find project root (directory that contains tb/top/shared_memory_tb.sv)
find_project_root() {
    local dir="$1"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/tb/top/shared_memory_tb.sv" ]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "$SCRIPT_DIR/.."
}

ROOT="$(cd "$(find_project_root "$SCRIPT_DIR")" && pwd)"
cd "$ROOT"

echo "Project root: $ROOT"

LOG_DIR="$ROOT/sim/logs"
SUMMARY_FILE="$LOG_DIR/coverage_summary.txt"

# --- resolve filenames (server may use typo names) ---
resolve_fac_pkg() {
    local found candidate
    for candidate in \
        tb/agents/fac/fac_agent.pkg.sv \
        tb/agents/fac/fac_agent_pkg.sv \
        agents/fac/fac_agent.pkg.sv \
        agents/fac/fac_agent_pkg.sv; do
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done
    found="$(find . -path '*/fac/fac_agent*.sv' -o -path '*/fac/fac_agent.pkg.sv' 2>/dev/null | head -1)"
    if [ -n "$found" ] && [ -f "$found" ]; then
        echo "$found"
        return 0
    fi
    echo "ERROR: fac agent package not found." >&2
    echo "  Looked in: tb/agents/fac/" >&2
    if [ -d tb/agents/fac ]; then
        echo "  Found in tb/agents/fac/:" >&2
        ls -1 tb/agents/fac/ >&2
    else
        echo "  Directory tb/agents/fac/ does not exist." >&2
        echo "  Make sure you run from shared_memory_verification/ (with rtl/ and tb/)." >&2
    fi
    exit 1
}

resolve_bt_if() {
    local candidate
    for candidate in rtl/bt_wirte_if.sv rtl/bt_write_if.sv; do
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done
    echo "ERROR: BT interface file not found (bt_wirte_if.sv or bt_write_if.sv)." >&2
    exit 1
}

FAC_PKG="$(resolve_fac_pkg)"
BT_IF="$(resolve_bt_if)"

# --- defaults ---
TEST_ARG="sanity"
DO_CLEAN=0
ENABLE_IMC=0
ENABLE_GUI=0
SAVE_LOGS=0
OPEN_IMC_GUI=0
COV_FRESH=0

# --- parse args ---
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            sed -n '2,16p' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        --clean)
            DO_CLEAN=1
            shift
            ;;
        --imc)
            ENABLE_IMC=1
            shift
            ;;
        --imc-gui)
            ENABLE_IMC=1
            OPEN_IMC_GUI=1
            shift
            ;;
        --gui)
            ENABLE_GUI=1
            shift
            ;;
        --log)
            SAVE_LOGS=1
            shift
            ;;
        sanity|sanity_fac|fac|test_sanity_fac)
            TEST_ARG="sanity"
            shift
            ;;
        wifi|wifi_split|test_wifi_split)
            TEST_ARG="wifi"
            shift
            ;;
        bt|bt_split|test_bt_split)
            TEST_ARG="bt"
            shift
            ;;
        coverage|cov|test_coverage_regression|coverage_regression)
            TEST_ARG="coverage"
            shift
            ;;
        all|regression)
            TEST_ARG="all"
            shift
            ;;
        cov-all|cov_all|coverage-all|coverage_all|full-cov)
            TEST_ARG="cov-all"
            SAVE_LOGS=1
            shift
            ;;
        *)
            echo "Unknown argument: $1" >&2
            echo "Run: ./sim/run.sh --help" >&2
            exit 1
            ;;
    esac
done

map_test_name() {
    case "$1" in
        sanity)   echo "test_sanity_fac" ;;
        wifi)     echo "test_wifi_split" ;;
        bt)       echo "test_bt_split" ;;
        coverage) echo "test_coverage_regression" ;;
        *)        echo "$1" ;;
    esac
}

verify_coverage_test_files() {
    local missing=0

    echo "Checking coverage regression files ..."

    for f in \
        tb/tests/test_coverage_regression.sv \
        tb/tests/shared_memory_test_pkg.sv \
        tb/envs/shared_memory_coverage.sv; do
        if [ ! -f "$f" ]; then
            echo "ERROR: missing required file: $f" >&2
            missing=1
        fi
    done

    if [ -f tb/tests/shared_memory_test_pkg.sv ] && \
       ! grep -q 'test_coverage_regression.sv' tb/tests/shared_memory_test_pkg.sv; then
        echo "ERROR: tb/tests/shared_memory_test_pkg.sv does not include test_coverage_regression.sv" >&2
        missing=1
    fi

    if [ "$missing" -ne 0 ]; then
        echo "" >&2
        echo "Fix: copy these files from your PC to the server (keep directory structure):" >&2
        echo "  tb/tests/test_coverage_regression.sv" >&2
        echo "  tb/tests/shared_memory_test_pkg.sv" >&2
        echo "  tb/envs/shared_memory_coverage.sv" >&2
        echo "  sim/run.sh" >&2
        echo "  sim/run_coverage.sh" >&2
        echo "" >&2
        echo "Then run: rm -rf xcelium.d && ./sim/run_coverage.sh --clean" >&2
        exit 1
    fi
}

extract_cov_lines() {
    local log_file="$1"
    local uvm_test="$2"
    if [ -f "$log_file" ]; then
        echo "=== $uvm_test ===" >> "$SUMMARY_FILE"
        grep -E '\[COV\]|test_coverage_regression|Regression done|PASS=|FAIL=' "$log_file" >> "$SUMMARY_FILE" || true
        echo "" >> "$SUMMARY_FILE"
    fi
}

run_one_test() {
    local uvm_test="$1"
    local cov_flags=""
    local run_mode="-batch"
    local log_args=()
    local log_file=""

    if [ "$ENABLE_GUI" = "1" ]; then
        run_mode="-gui"
    fi

    if [ "$ENABLE_IMC" = "1" ]; then
        cov_flags="-coverage functional -covfile sim/cov.ccf -covtest ${uvm_test}"
        if [ "$COV_FRESH" = "1" ]; then
            cov_flags="$cov_flags -covoverwrite"
        fi
    fi

    if [ "$SAVE_LOGS" = "1" ]; then
        mkdir -p "$LOG_DIR"
        log_file="$LOG_DIR/${uvm_test}.log"
        log_args=(-l "$log_file")
    fi

    echo "============================================================"
    echo " Running: $uvm_test"
    echo " Project: $ROOT"
    echo " Mode:    $run_mode"
    if [ -n "$log_file" ]; then
        echo " Log:     $log_file"
    fi
    if [ "$ENABLE_IMC" = "1" ]; then
        echo " IMC:     functional coverage -> cov_work/ (test=${uvm_test})"
    fi
    echo "============================================================"

    xrun -sv -uvm -timescale 1ns/1ps -access +rwc $run_mode \
        "${log_args[@]}" \
        $cov_flags \
        -incdir rtl \
        -incdir tb/agents/fac \
        -incdir tb/agents/wifi \
        -incdir tb/agents/bt \
        -incdir tb/agents/read \
        -incdir tb/interfaces \
        -incdir tb/envs \
        -incdir tb/seqs \
        -incdir tb/tests \
        rtl/shared_memory_pkg.sv \
        "$FAC_PKG" \
        tb/agents/wifi/wifi_agent_pkg.sv \
        tb/agents/bt/bt_agent_pkg.sv \
        tb/agents/read/read_agent_pkg.sv \
        tb/envs/shared_memory_env_pkg.sv \
        tb/seqs/fac_seq_pkg.sv \
        tb/seqs/wifi_seq_pkg.sv \
        tb/seqs/bt_seq_pkg.sv \
        tb/seqs/read_seq_pkg.sv \
        tb/seqs/common_seq_pkg.sv \
        tb/tests/shared_memory_test_pkg.sv \
        rtl/async_fifo.sv \
        "$BT_IF" \
        rtl/fac_write_if.sv \
        rtl/wifi_write_if.sv \
        rtl/dual_port_ram.sv \
        rtl/interface_mux.sv \
        rtl/mem_status_ctrl.sv \
        rtl/read_ctrl.sv \
        rtl/shared_memory.sv \
        rtl/write_ctrl.sv \
        tb/agents/fac/fac_if.sv \
        tb/agents/wifi/wifi_if.sv \
        tb/agents/bt/bt_if.sv \
        tb/agents/read/read_if.sv \
        tb/interfaces/ctrl_if.sv \
        tb/top/shared_memory_tb.sv \
        +UVM_TESTNAME="$uvm_test"

    if [ -n "$log_file" ]; then
        extract_cov_lines "$log_file" "$uvm_test"
    fi
}

run_regression() {
    local tests=("$@")
    local PASS=0
    local FAIL=0
    local t uvm_test
    local first_cov=1

    for t in "${tests[@]}"; do
        uvm_test="$(map_test_name "$t")"
        if [ "$ENABLE_IMC" = "1" ]; then
            if [ "$first_cov" = "1" ]; then
                COV_FRESH=1
                first_cov=0
            else
                COV_FRESH=0
            fi
        fi
        if run_one_test "$uvm_test"; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi
    done

    echo "============================================================"
    echo " Regression done: PASS=$PASS  FAIL=$FAIL"
    echo "============================================================"

    if [ "$SAVE_LOGS" = "1" ]; then
        echo "Regression done: PASS=$PASS  FAIL=$FAIL" >> "$SUMMARY_FILE"
        echo "Coverage summary: $SUMMARY_FILE"
    fi

    if [ "$ENABLE_IMC" = "1" ] && [ "$FAIL" -eq 0 ]; then
        echo "IMC database: $ROOT/cov_work/"
        echo "Open GUI:       ./sim/run_imc.sh"
    fi

    [ "$FAIL" -eq 0 ]
}

open_imc_gui() {
    if [ -x "$SCRIPT_DIR/run_imc.sh" ]; then
        bash "$SCRIPT_DIR/run_imc.sh"
    else
        echo "Run: ./sim/run_imc.sh" >&2
    fi
}

if [ "$DO_CLEAN" = "1" ]; then
    echo "Cleaning xcelium.d ..."
    rm -rf xcelium.d
fi

if [ "$ENABLE_GUI" = "1" ] && { [ "$TEST_ARG" = "all" ] || [ "$TEST_ARG" = "cov-all" ]; }; then
    echo "ERROR: SimVision GUI does not support multi-test regression." >&2
    echo "  Use: ./sim/run_gui.sh sanity|wifi|bt|coverage" >&2
    exit 1
fi

if [ "$TEST_ARG" = "cov-all" ]; then
    verify_coverage_test_files
    ENABLE_IMC=1
    if [ "$DO_CLEAN" = "1" ] || [ ! -d cov_work ]; then
        echo "Resetting IMC database (cov_work/) ..."
        rm -rf cov_work
    fi
    mkdir -p "$LOG_DIR"
    : > "$SUMMARY_FILE"
    echo "Functional coverage regression — $(date)" >> "$SUMMARY_FILE"
    echo "" >> "$SUMMARY_FILE"
    run_regression sanity wifi bt coverage
    if [ "$OPEN_IMC_GUI" = "1" ]; then
        open_imc_gui
    fi
elif [ "$TEST_ARG" = "all" ]; then
    run_regression sanity wifi bt
else
    if [ "$TEST_ARG" = "coverage" ]; then
        verify_coverage_test_files
        if [ "$ENABLE_IMC" = "1" ]; then
            COV_FRESH=1
            rm -rf cov_work
        fi
    fi
    if [ "$TEST_ARG" = "coverage" ] && [ "$SAVE_LOGS" = "0" ]; then
        SAVE_LOGS=1
        mkdir -p "$LOG_DIR"
        : > "$SUMMARY_FILE"
        echo "Functional coverage — $(date)" >> "$SUMMARY_FILE"
        echo "" >> "$SUMMARY_FILE"
    fi
    run_one_test "$(map_test_name "$TEST_ARG")"
    if [ "$TEST_ARG" = "coverage" ]; then
        echo "Coverage summary: $SUMMARY_FILE"
        if [ "$ENABLE_IMC" = "1" ]; then
            echo "IMC database: $ROOT/cov_work/"
            echo "Open GUI:     ./sim/run_imc.sh"
            if [ "$OPEN_IMC_GUI" = "1" ]; then
                open_imc_gui
            fi
        fi
    fi
fi

