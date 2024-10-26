
# for testing
FLOW_HOME ?= ..
TESTING_PLATFORM ?= mfda_30px
PLATFORM ?= $(TESTING_PLATFORM)

V_PRE_TOOL_HOME = $(FLOW_HOME)/../tools/verilog_preparser/

RESULTS_DIR ?= $(FLOW_HOME)/results/$(DESIGN)/$(DESIGN_VARIANT)

PCELL_LEF ?= $(V_PRE_TOOL_HOME)/lef/p_cell_serpentines.lef

P_CELL_SCRIPT = $(V_PRE_TOOL_HOME)/verilog_param_preparse.py

# PCELL_MERGE_LEF=$(OPENROAD_FLOW_DIR)/platforms/$(PLATFORM)/lef/$(PLATFORM)_merged_w_pcells.lef
ORIG_LEF = $(FLOW_HOME)/platforms/$(PLATFORM)/lef/$(PLATFORM)_merged.lef

PCELL_MERGE_LEF = $(RESULTS_DIR)/$(PLATFORM)_$(DESIGN)_pcells.lef
DESIGN_PCELL_MERGE = $(V_PRE_TOOL_HOME)/designs/$(DESIGN)/$(PLATFORM)/prev_out_pcell.lef

VERILOG_SRC = $(FLOW_HOME)/designs/src/$(DESIGN)/$(DESIGN).v

.PHONY: verilog_preparse
verilog_preparse: 

.PHONY: pnr_pre
pnr_pre: $(DESIGN_PCELL_MERGE)

#--pcell_lef $(OPENROAD_FLOW_DIR)/platforms/$(PLATFORM)/lef/$(PLATFORM)_merged_pcellonly.lef 
#$(OPENROAD_FLOW_DIR)/verilog_preparser/designs/$(DESIGN)/$(PLATFORM)/out_merge_pcell.lef
$(PCELL_MERGE_LEF) $(DESIGN_PCELL_MERGE): $(VERILOG_SRC) $(PCELL_LEF)
	mkdir -p $(RESULTS_DIR)
	python3 $(P_CELL_SCRIPT) \
		 --netlist $(VERILOG_SRC) \
		 --orig_lef $(ORIG_LEF) \
		 --out_lef $(PCELL_MERGE_LEF) \
		 --pcell_lef $(PCELL_LEF) \
		 --out_lef_csv $(RESULTS_DIR)/preparse.csv \
		 --conversion_file_dir $(RESULTS_DIR)

ifneq (,$(wildcard $(PCELL_MERGE_LEF)))
export ADDITIONAL_LEFS += $(PCELL_MERGE_LEF)
endif

ifneq (,$(wildcard $(RESULTS_DIR)/pcell_out_scad))
SCAD_ARGS += --pcell_file $(RESULTS_DIR)/pcell_out_scad
endif
ifneq (,$(wildcard $(RESULTS_DIR)/pcell_out_xyce))
SIMULATION_ARGS += --pcell_file $(RESULTS_DIR)/pcell_out_xyce
endif

# Testing ----------------------------------------------------------

TESTING_PCELL_DIR=./pcells/serpentine
TESTING_PCELL_MERGE_OUT=base_merge_pcell.lef
TESTING_PCELL_MERGE_CP_LOC=../platforms/$(TESTING_PLATFORM)/lef/$(TESTING_PLATFORM)_pcell_pre.lef

build_merge_pcell_lef:
	rm -f $(TESTING_PCELL_MERGE_OUT)
	touch $(TESTING_PCELL_MERGE_OUT)
	find $(TESTING_PCELL_DIR) -type f -name '*.lef' -exec cut -b 1- {} + >> $(TESTING_PCELL_MERGE_OUT)

cp_merge_lef:
	cp $(TESTING_PCELL_MERGE_OUT) $(TESTING_PCELL_MERGE_CP_LOC)
