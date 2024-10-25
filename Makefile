
# for testing
FLOW_HOME ?= .
TESTING_PLATFORM ?= mfda_30px
PLATFORM ?= $(TESTING_PLATFORM)

PCELL_LEF ?= $(FLOW_HOME)/../verilog_preparser/lef/p_cell_serpentines.lef

P_CELL_SCRIPT = $(FLOW_HOME)/../verilog_preparser/verilog_param_preparse.py

# PCELL_MERGE_LEF=$(OPENROAD_FLOW_DIR)/platforms/$(PLATFORM)/lef/$(PLATFORM)_merged_w_pcells.lef
ORIG_LEF = $(FLOW_HOME)/platforms/$(PLATFORM)/lef/$(PLATFORM)_merged.lef

PCELL_MERGE_LEF = $(FLOW_HOME)/results/$(DESIGN)/$(DESIGN_VARIANT)/$(PLATFORM)_$(DESIGN)_w_pcells.lef
DESIGN_PCELL_MERGE = $(FLOW_HOME)/verilog_preparser/designs/$(DESIGN)/$(PLATFORM)/prev_out_pcell.lef

VERILOG_SRC = $(FLOW_HOME)/designs/src/$(DESIGN)/$(DESIGN).v

.PHONY: verilog_preparse
verilog_preparse: 

.PHONY: pnr_pre
pnr_pre: $(DESIGN_PCELL_MERGE)

#--pcell_lef $(OPENROAD_FLOW_DIR)/platforms/$(PLATFORM)/lef/$(PLATFORM)_merged_pcellonly.lef 
#$(OPENROAD_FLOW_DIR)/verilog_preparser/designs/$(DESIGN)/$(PLATFORM)/out_merge_pcell.lef
$(PCELL_MERGE_LEF) $(DESIGN_PCELL_MERGE): $(VERILOG_SRC) $(PCELL_LEF)
	mkdir -p $(FLOW_HOME)/results/$(DESIGN)/$(DESIGN_VARIANT)
	python3 $(P_CELL_SCRIPT) \
		 --netlist $(VERILOG_SRC) \
		 --orig_lef $(ORIG_LEF) \
		 --out_lef $(PCELL_MERGE_LEF) \
		 --pcell_lef $(PCELL_LEF) \
		 --out_lef_csv $(FLOW_HOME)/results/$(DESIGN)/$(DESIGN_VARIANT)/preparse.csv \
		 --conversion_file_dir $(FLOW_HOME)/results/$(DESIGN)/$(DESIGN_VARIANT)

export ADDITIONAL_LEFS += $(PCELL_MERGE_LEF)

SCAD_PCELL_ARG += --pcell_file $(FLOW_HOME)/results/$(DESIGN)/$(DESIGN_VARIANT)/pcell_out_scad
XYCE_PCELL_ARG += --pcell_file $(FLOW_HOME)/results/$(DESIGN)/$(DESIGN_VARIANT)/pcell_out_xyce

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
