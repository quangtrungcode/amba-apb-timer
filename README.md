# 64-bit Timer IP Design & Functional Verification

A production-grade 64-bit Timer IP customized from the RISC-V CLINT architecture, interfacing via the AMBA 3 APB protocol. Designed and functionally verified with Verilog HDL and industry-standard EDA simulation flows.

---

## Key Features

### RTL Design 
* **Bus Interface**: AMBA APB Slave with a 12-bit address bus and 32-bit data bus.
* **Wait-State Insertion**: 1-cycle wait-state implementation using `tim_pready` to coordinate transfer timing.
* **Byte-Strobe Support**: Granular byte-level write access using `tim_pstrb[3:0]`.
* **Prohibited Access Protection**: Generates bus error response (`tim_pslverr`) and rejects illegal register writes (e.g., updating prescaler while active or loading out-of-range divider values).
* **64-bit Counter & Prescaler**: High-precision 64-bit count-up counter supporting system clock or divided clocks (prescaler divisors up to 256).
* **Debug Mode Halt**: Freezes counter progression on debug requests (`dbg_mode`, `halt_req`) and reports status via `halt_ack`.
* **Interrupt Generation**: Hardware maskable level interrupt (`tim_int`) triggered upon 64-bit threshold match, supporting high-priority Write-1-to-Clear (W1C) status handling.

### Verification 
* Formulated a comprehensive **Verification Plan (vPlan)** mapping register features, operational modes, and corner cases.
* Developed automated **self-checking testbenches** covering reset behavior, counter rollover, bus wait-states, and invalid access sequences.
* Achieved **100% Code Coverage** (Statement, Branch, Condition/FEC, Toggle) validated against the instructor's Golden Model.

---

## Microarchitecture

The IP is divided into 6 modular sub-blocks:
* `APB Slave`: Decodes APB protocol signals, generates internal read/write enables, and controls `tim_pready`.
* `Timer Control Register (TCR)`: Manages timer enable (`timer_en`), division enable (`div_en`), division value (`div_val`), and error detection logic.
* `Timer Compare Register (TCMP0/1)`: Stores the 64-bit compare threshold (`tcmp[63:0]`) across two 32-bit byte-accessible registers.
* `Timer Interrupt Register (TIER/TISR)`: Implements interrupt mask bit, 64-bit comparator matching, and W1C pending logic.
* `Counter Control`: Generates the single-cycle `cnt_en` pulse based on prescaler division limits and debug halt signals.
* `Counter (TDR0/1)`: 64-bit count-up core built with 8-byte parallel data slices and hardware auto-clear logic on timer disable.

---

## Register Map

| Address | Abbreviation | Register name |
| :--- | :--- | :--- |
| `0x00` | TCR | Timer Control Register |
| `0x04` | TDR0 | Timer Data Register 0 |
| `0x08` | TDR1 | Timer Data Register 1 |
| `0x0C` | TCMP0 | Timer Compare Register 0 |
| `0x10` | TCMP1 | Timer Compare Register 1 |
| `0x14` | TIER | Timer Interrupt Enable Register |
| `0x18` | TISR | Timer Interrupt Status Register |
| `0x1C` | THCSR | Timer Halt Control Status Register |
| Others | Reserved | — |

---

## Repository Structure

```text
├── Design/
│   ├── rtl/
│   │   ├── APB_Slave.v                 # APB protocol decoder & wait-state generation
│   │   ├── cnt_ctrl.v                  # Prescaler logic & debug halt controller
│   │   ├── counter.v                   # 64-bit count-up core with byte-sliced registers
│   │   ├── interrupt.v                 # 64-bit threshold comparator & W1C interrupt logic
│   │   ├── tcmp.v                      # Compare registers (TCMP0 & TCMP1)
│   │   ├── tcr.v                       # Timer Control Register with error detection logic
│   │   └── timer_top.v                 # Top-level IP integration
│   └── Timer_Design_Specification.pdf  # Comprehensive architecture & timing specification
└── Verification/
    ├── sim/                            # Simulation environment & execution flows
    │   ├── coverage/                   # Generated coverage reports (summary & detail)
    │   │   ├── detail_report.txt
    │   │   └── summary_report.txt
    │   ├── log/                        # Simulation run logs
    │   ├── Makefile                    # Automation build script
    │   ├── compile.f, rtl.f, tb.f      # Compilation file lists
    │   ├── pat.list                    # Regression test suite list
    │   ├── run.csh, report.csh         # Shell automation scripts
    │   └── TrungQuang.do               # Simulator wave/do script
    ├── tb/
    │   ├── apb_tasks.v                 # Reusable APB bus master driver tasks
    │   └── test_bench.v                # Top-level testbench wrapper & clock/reset generator
    ├── testcases/                      # Directed test cases covering all verification targets
    │   ├── apb_multiple_access.v       # Back-to-back transfer validation
    │   ├── apb_protocol_chk.v          # APB setup/access phase & wait-state check
    │   ├── apb_unaligned_chk.v         # Byte-strobe & unaligned access check
    │   ├── cnt_counting_chk.v          # Clock division & counter rollover verification
    │   ├── cnt_ctrl_chk.v              # Counter control state transitions
    │   ├── halt_mode_chk.v             # Debug halt/resume sequence verification
    │   ├── interrupt_chk.v             # Interrupt assertion on match condition
    │   ├── interrupt_rst_chk.v         # Interrupt status reset behavior
    │   ├── reg_err_chk.v               # Prohibited configuration & pslverr response check
    │   ├── reg_init_chk.v              # Power-on default register checks
    │   ├── reg_one_hot_chk.v           # Walking bit / one-hot register checks
    │   ├── reg_reserved_chk.v          # Reserved address space protection
    │   ├── reg_rst_chk.v               # Reset behavior across register set
    │   └── reg_rw_chk.v                # Read/write functional integrity checks
    ├── Final_Project-2.xlsx            # Project requirements & tracking matrix
    └── Timer_vplan.xlsx                # Detailed Verification Plan (vPlan)
