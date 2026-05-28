VSIM     = questa
SCRIPTS  = scripts
SIM_DIR  = sim

# ============================================================================
# Unit modules
# ============================================================================
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

# ============================================================================
# Top-level modules
# ============================================================================
ALL_TOPS = \
	risc_top

.PHONY: \
	sim wave \
	sim-top wave-top \
	all all-top \
	clean clean_all report \
	$(ALL_MODULES) \
	$(ALL_TOPS)

# ============================================================================
# UNIT SIMULATION
# ============================================================================

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

# ============================================================================
# TOP-LEVEL SIMULATION
# ============================================================================

sim-top:
ifndef TOP
	$(error Thieu TOP. Vi du: make sim-top TOP=risc_top)
endif
	@mkdir -p $(SIM_DIR)/$(TOP)

	$(VSIM) -c \
	    -l $(SIM_DIR)/$(TOP)/$(TOP).log \
	    -do "set TOP $(TOP); source $(SCRIPTS)/run_top.tcl"

wave-top:
ifndef TOP
	$(error Thieu TOP. Vi du: make wave-top TOP=risc_top)
endif
	@mkdir -p $(SIM_DIR)/$(TOP)

	$(VSIM) \
	    -l $(SIM_DIR)/$(TOP)/$(TOP).log \
	    -do "set TOP $(TOP); source $(SCRIPTS)/run_top.tcl"

# ============================================================================
# RUN ALL UNIT TESTS
# ============================================================================

all: $(ALL_MODULES)
	@$(MAKE) report

$(ALL_MODULES):
	@mkdir -p $(SIM_DIR)/$@

	$(VSIM) -c \
	    -l $(SIM_DIR)/$@/$@.log \
	    -do "set MODULE $@; source $(SCRIPTS)/run_unit.tcl"; true

# ============================================================================
# RUN ALL TOP TESTS
# ============================================================================

all-top: $(ALL_TOPS)

$(ALL_TOPS):
	@mkdir -p $(SIM_DIR)/$@

	$(VSIM) -c \
	    -l $(SIM_DIR)/$@/$@.log \
	    -do "set TOP $@; source $(SCRIPTS)/run_top.tcl"; true

# ============================================================================
# REPORT
# ============================================================================

report:
	@echo ""
	@echo "===== UNIT SIMULATION REPORT ====="

	@for m in $(ALL_MODULES); do \
	    log=$(SIM_DIR)/$$m/$$m.log; \
	    if [ -f "$$log" ]; then \
	        echo "  [DONE] $$m"; \
	    else \
	        echo "  [SKIP] $$m"; \
	    fi \
	done

	@echo "=================================="

# ============================================================================
# CLEAN
# ============================================================================

clean:
ifndef MODULE
	$(error Thieu MODULE. Vi du: make clean MODULE=alu)
endif
	rm -rf $(SIM_DIR)/$(MODULE)

clean_all:
	rm -rf $(SIM_DIR)

