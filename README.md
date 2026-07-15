# RV32I Single-Cycle CPU — SystemVerilog Version

A modular 32-bit RV32I educational core written in SystemVerilog. The repository includes unit-level self-checking testbenches, an integrated software-driven CPU test, reusable Questa/ModelSim scripts and Quartus project artifacts.

## Current status

| Item | Status |
|---|---|
| Single-cycle CPU RTL | Implemented |
| Unit verification | Implemented for 8 blocks with committed PASS logs |
| Integrated CPU test | Implemented; committed log reports 10 PASS / 0 FAIL |
| Functional coverage | Drafted in one test but currently commented out |
| FPGA Quartus artifacts | Included |
| ISA compliance | Not performed |

## Microarchitecture

```text
Program Counter -> Instruction ROM -> Decode / Immediate Generator
       |                         |                 |
       +-> PC+4 / PC+imm         v                 v
                         Register File -> ALU input muxes -> ALU
                               ^                         |
                               |                         v
                               +------ Write-back <- Data RAM
```

The processor is single-cycle rather than pipelined. The PC and register-file write port are clocked; instruction decode, ALU, branch selection, memory read and write-back selection form the combinational instruction path.

### Top-level interface

```systemverilog
module risc_top (
    input logic clk,
    input logic rstn
);
```

`rstn` is sampled synchronously by the program counter. Internal debug registers use asynchronous active-low reset and are preserved for FPGA observation.

### RTL hierarchy

| Module | Function |
|---|---|
| `risc_top` | CPU integration |
| `program_counter` | Synchronous active-low reset, next-PC register |
| `instruction_memory` | 32-word simulation ROM loaded from `program.hex` |
| `control_unit` | Opcode/funct decode and control generation |
| `register_file` | 32 x 32-bit, two async read ports and one sync write port |
| `immediate_generator` | U/J/B/I/S/shift immediate decode |
| `alu_src_a_mux`, `alu_src_b_mux` | ALU operand selection |
| `alu` | Ten arithmetic/logic/compare/shift operations |
| `pc_adder`, `pc_imm`, `branch_unit` | Sequential, branch and jump PC paths |
| `data_memory` | 64-word RAM with byte/halfword/word accesses |
| `write_back_mux` | ALU, memory, PC+4 or immediate result selection |

## Supported instruction classes

- U-type: `LUI`, `AUIPC`;
- jumps: `JAL`, `JALR`;
- branches: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`;
- loads: `LB`, `LH`, `LW`, `LBU`, `LHU`;
- stores: `SB`, `SH`, `SW`;
- register ALU: `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`;
- immediate ALU: `ADDI`, `SLLI`, `SLTI`, `SLTIU`, `XORI`, `SRLI`, `SRAI`, `ORI`, `ANDI`.

Unsupported opcodes decode to a safe no-write/default-PC action. The core has not been run through the official RISC-V architectural test suite, so the list describes implemented decode intent rather than compliance certification.

## Memory organization

| Memory | Capacity | Read/write behavior |
|---|---:|---|
| Instruction | 32 x 32-bit words | Combinational read, `$readmemh` initialization |
| Data | 64 x 32-bit words | Combinational read, synchronous byte-lane writes |

The simulation scripts run from `sim/<target>/`, matching the relative instruction-file path in `instruction_memory.sv`.

## Repository structure

```text
.
├── src/
│   ├── core/
│   └── memory/
├── tb/                 # Unit and integration testbenches
├── scripts/            # Questa compile/run configuration
├── sim/                # Committed logs/wave databases
├── fpga/               # Quartus project and timing constraint
├── doc/                # Architecture and ISA references
└── Makefile
```

## Verification evidence

Committed logs currently report:

| Test | Result in repository |
|---|---|
| ALU | 13 PASS / 0 FAIL |
| ALU input muxes | 2 + 2 PASS / 0 FAIL |
| Branch unit | 15 PASS / 0 FAIL |
| Control unit | 18 PASS / 0 FAIL |
| Immediate generator | 6 PASS / 0 FAIL |
| PC adder | 5 PASS / 0 FAIL |
| Register file | 6 PASS / 0 FAIL |
| Integrated `risc_top` program | 10 PASS / 0 FAIL |

The integrated test checks registers x1..x10 after executing `src/memory/program.hex`.

### Run one unit test

```bash
make sim MODULE=alu
make wave MODULE=alu
```

Valid configured unit names include:

```text
alu alu_src_a_mux alu_src_b_mux branch_unit control_unit
immediate_generator pc_adder program_counter register_file
```

### Run the integrated CPU test

```bash
make sim-top TOP=risc_top
make wave-top TOP=risc_top
```

### Run the batch list

```bash
make all
make report
```

## Verification caveats

- `tb/program_counter/tb_program_counter.sv` connects a port named `rst`, while the DUT port is `rstn`; this unit test requires correction before it compiles.
- The `all` targets append `true`, so an individual simulator failure does not stop the Makefile. The current report checks whether a log exists, not whether the log contains zero failures.
- Data memory, instruction memory, `pc_imm` and write-back mux do not have dedicated configured unit regressions.
- The branch functional-coverage code is currently commented out.
- Testbench reference functions mirror parts of the RTL decode; an independent ISA model would provide stronger verification.

## Known architectural limitations

- No CSR, interrupt, exception, privilege, compressed, atomic or M-extension support.
- No pipeline, cache, branch prediction or memory wait-state interface in this standalone top.
- No trap for illegal instructions, misaligned PC/data accesses or memory bounds.
- Register/data memories are not reset as architectural arrays.
- The repository contains generated simulator and FPGA files; source RTL, testbenches, scripts and constraints should be treated as authoritative.

## Recommended sign-off path

1. Fix the program-counter unit test and make regression failures propagate to the shell.
2. Add unit tests for every unverified block and SVA for key invariants.
3. Run lint, synthesis and STA with explicit clock/reset constraints.
4. Add an instruction-by-instruction reference model and official RV32I compliance tests.

