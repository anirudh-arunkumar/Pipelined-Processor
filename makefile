TARBALL = ece3058_lab2_submission.tar.gz

all: sim

mips_tb: CONTROL.sv DMEMORY.sv EXECUTE.sv IDECODE.sv IFETCH.sv MIPS.sv MIPS_tb.sv STALL_CONT.sv WRITE_BACK.sv FWD_CONT.sv
	iverilog -g2005-sv -s MIPS_pipelined_tb -o $@ $^

sim: mips_tb
	vvp $<

submit: clean
	tar -czvf $(TARBALL) $(wildcard *.sv)
	@echo
	@echo 'Submission tarball written to' $(TARBALL)
	@echo 'Please decompress it yourself and make sure it looks right!'
	@echo 'Then submit it to Gradescope'


clean:
	rm -f mips_tb sim.vcd $(TARBALL)
