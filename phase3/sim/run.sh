#!/bin/bash
BASE=".."
TEST="$1"

if [[ $# -ne 1 ]]; then
	printf "Usage:\n  ./run.sh testname # corresponds to ../testcases/testname.list\n"
	exit
fi

LIST="$BASE/testcases/${TEST}.list"
if [[ ! -f $LIST ]]; then
	printf "$LIST does not exist. Exiting."
	exit
fi

perl $BASE/WISC-assembler/assembler.pl $LIST > loadfile_instr.img
touch loadfile_data.img # empty data memory image

# This is for Icarus Verilog
iverilog -g2001 $BASE/dv/wisc_trace_p3.v $BASE/dv/phase3_cpu_tb.v $BASE/ip/dv/data_way_array_beh.v $BASE/ip/dv/metadata_way_array_beh.v $BASE/ip/memory4c.v $BASE/design/common/flags.vh $BASE/design/common/*.v $BASE/design/pipelines/*.v $BASE/design/alu_ops/*.v $BASE/design/register_file/*.v $BASE/design/*.v -g2005-sv -v && vvp a.out

mv verilogsim.log $TEST.log
mv verilogsim.trace $TEST.trace
