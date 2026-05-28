VSIM     = questa
SCRIPTS  = scripts
SIM_DIR  = sim

ALL_MODULES = \
	alu \
	alu_src_a_mux \
	alu_src_b_mux \
	branch_unit \
	control_unit \
	immediate_generator \
	pc_adder \
	program_counter \
	register_file

.PHONY: sim wave all clean clean_all report $(ALL_MODULES)

sim:
ifndef MODULE
	$(error Thieu MODULE. Vi du: make sim MODULE=alu)
endif
	@mkdir -p $(SIM_DIR)/$(MODULE)
	$(VSIM) -c \
	    -l $(SIM_DIR)/$(MODULE)/$(MODULE).log \
	    -do "set MODULE $(MODULE); source $(SCRIPTS)/run_unit.tcl"

wave:
ifndef MODULE
	$(error Thieu MODULE. Vi du: make wave MODULE=alu)
endif
	@mkdir -p $(SIM_DIR)/$(MODULE)
	$(VSIM) \
	    -l $(SIM_DIR)/$(MODULE)/$(MODULE).log \
	    -do "set MODULE $(MODULE); source $(SCRIPTS)/run_unit.tcl"

all: $(ALL_MODULES)
	@$(MAKE) report

$(ALL_MODULES):
	@mkdir -p $(SIM_DIR)/$@
	$(VSIM) -c \
	    -l $(SIM_DIR)/$@/$@.log \
	    -do "set MODULE $@; source $(SCRIPTS)/run_unit.tcl"; true

report:
	@echo ""
	@echo "===== SIMULATION REPORT ====="
	@for m in $(ALL_MODULES); do \
	    log=$(SIM_DIR)/$$m/$$m.log; \
	    if [ -f "$$log" ]; then \
	        echo "  [DONE] $$m"; \
	    else \
	        echo "  [SKIP] $$m"; \
	    fi \
	done
	@echo "============================="

clean:
ifndef MODULE
	$(error Thieu MODULE. Vi du: make clean MODULE=alu)
endif
	rm -rf $(SIM_DIR)/$(MODULE)

clean_all:
	rm -rf $(SIM_DIR)
