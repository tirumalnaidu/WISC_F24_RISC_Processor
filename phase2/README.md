### File Hierarchy
---
```bash
phase2
├── WISC-assembler
│   ├── README
│   ├── assembler.pl
│   └── sample
├── design
│   ├── a.out
│   ├── alu_16bit.v
│   ├── bit_cell.v
│   ├── common
│   │   ├── addsub_16bit.v
│   │   ├── cla_adder_4bit.v
│   │   ├── dff.v
│   │   ├── flags.vh
│   │   ├── loadfile_data.img
│   │   ├── loadfile_instr.img
│   │   ├── memory1c_data.v
│   │   ├── memory1c_instr.v
│   │   ├── pldff.v
│   │   ├── ror_func.v
│   │   ├── sll_func.v
│   │   └── sra_func.v
│   ├── control_unit.v
│   ├── cpu.v
│   ├── ex_mem_pipe.v
│   ├── forward_unit.v
│   ├── hazard_unit.v
│   ├── id_ex_pipe.v
│   ├── if_id_pipe.v
│   ├── mem_wb_pipe.v
│   ├── paddsub_16bit.v
│   ├── pc_control.v
│   ├── pc_update.v
│   ├── read_decoder_4_16.v
│   ├── red_16bit.v
│   ├── register.v
│   ├── register_file.v
│   ├── shifter.v
│   ├── write_decoder_4_16.v
│   └── xor_16bit.v
├── dv
│   ├── phase2_cpu_tb.v
│   └── wisc_trace_p2.v
├── ip
│   ├── dff.v
│   ├── dv
│   │   ├── dff_tb.v
│   │   ├── memory1c_tb.v
│   │   └── pldff_tb.v
│   ├── memory1c.readme.txt
│   ├── memory1c_data.v
│   ├── memory1c_instr.v
│   ├── pldff.v
│   └── run.sh
├── sim
│   ├── a.out
│   ├── dump.vcd
│   ├── dumpfile_data.img
│   ├── loadfile_data.img
│   ├── loadfile_instr.img
│   └── run.sh
└── testcases
    ├── test1.list
    ├── test2.list
    └── test3.list

