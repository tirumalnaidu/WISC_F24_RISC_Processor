### File Hierarchy
---
```bash
phase1
├── WISC-assembler
│   ├── README                # Instructions on how to run assembler.pl
│   ├── assembler.pl          # Perl script to assemble text-level test cases into machine code
│   └── sample                # Sample files for the assembler
├── design                    # Your Verilog design files go here
│   ├── cpu.v                
│   ├── cla.v                
│   ├── reduction_cla.v                
│   ├── register_file.v                
│   └── shifter.v                
├── dv
│   ├── phase1_cpu_tb.v       # Testbench file, use this and modify as needed
├── ip
│   ├── dff.v                 # D flip-flop to use in your design
│   ├── dv
│   │   ├── dff_tb.v          # Testbench for D flip-flop
│   │   └── memory1c_tb.v     # Testbench for memory
│   ├── memory1c.readme.txt   # Instructions for the memory1c module
│   ├── memory1c_data.v       # Use this module for Data Memory
│   └── memory1c_instr.v      # Use this module for Instruction Memory
├── sim
│   └── run.sh                # Example script to run a test using Icarus Verilog
└── testcases                 # Testcases for the processor. Ensure these work correctly
    ├── test1.list
    ├── test2.list
    └── test3.list
```

### Module Hierarchy
---
``` bash
cpu 
├── alu                 - yash
│    ├── addsub
│    │   └── cla        
│    ├── paddsub        
│    │   └── cla
│    ├── reduction_cla  
│    │   └── cla
│    ├── xor            
│    └── shifter        - DONE
├── register_file       - DONE
├── sign_extend         - DONE
├── control             - tirumal
├── alu_control         - tirumal
├── pc_control          - balaji
├── memory1c_data       - DONE
└── memory1c_inst       - DONE
```