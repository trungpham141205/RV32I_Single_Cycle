# =============================================================================
# top_cfg.tcl
# =============================================================================

set TOP_CFG(risc_top) [dict create \
    src {
        src/core/program_counter.sv
        src/memory/instruction_memory.sv
        src/core/control_unit.sv
        src/core/register_file.sv
        src/core/immediate_generator.sv
        src/core/alu_src_a_mux.sv
        src/core/alu_src_b_mux.sv
        src/core/alu.sv
        src/memory/data_memory.sv
        src/core/write_back_mux.sv
        src/core/pc_adder.sv
        src/core/pc_imm.sv
        src/core/branch_unit.sv
        src/core/risc_top.sv
    } \
    tb {
        tb/risc_top/tb_risc_top.sv
    } \
    top tb_risc_top \
]

# -----------------------------------------------------------------------------
# Helper
# -----------------------------------------------------------------------------
proc get_all_top_modules {} {
    global TOP_CFG
    return [array names TOP_CFG]
}
