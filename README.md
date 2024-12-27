# WISC-F24 RISC Processor Design and Implementation
This repository contains the Verilog implementation of a WISC-F24 processor developed as part of the ECE/CS 552: Introduction to Computer Architecture course at the University of Wisconsin-Madison. The project was executed in three phases, progressively enhancing the functionality and complexity of the processor. The final design is a 5-stage pipelined processor with an integrated cache hierarchy.


## Phase 1: Single-Cycle Processor
- **Objective:** Implement a single-cycle processor for the WISC-F24 ISA.
- **Key Features:**
  - 16-bit data path, load/store architecture.
  - Register file with 16 general-purpose registers and a 3-bit FLAG register.
  - Supported 16 instructions classified into Compute, Memory, and Control categories.
  - Modules include ALU, CLA-based adders, decoders, reduction unit, and shifter.

## Phase 2: 5-Stage Pipelined Processor
- **Objective:** Enhance the processor by introducing a 5-stage pipeline.
- **Pipeline Stages:**
  1. Instruction Fetch (IF)
  2. Instruction Decode (ID)
  3. Execute (EX)
  4. Memory Access (MEM)
  5. Write Back (WB)
- **Key Features:**
  - Hazard detection and data forwarding units.
  - Efficient pipeline control mechanisms.
  - Modular reuse of Phase 1 components.

## Phase 3: Cache Hierarchy Integration
- **Objective:** Integrate L1 caches for instructions (I-cache) and data (D-cache).
- **Key Features:**
  - 2-way set-associative caches with write-through and write-allocate policies.
  - Cache blocks of 16 bytes, 2KiB cache size.
  - Cache controllers with FSM for handling misses and memory arbitration.
  - Improved system performance through memory hierarchy.
