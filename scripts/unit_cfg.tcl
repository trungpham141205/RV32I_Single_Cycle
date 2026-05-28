# =============================================================================
# unit_cfg.tcl
# Cau hinh tung unit: ten module -> danh sach file can compile
# Format: set UNIT_CFG(<ten_module>) [list <src_files...> <tb_files...>]
# =============================================================================

array set UNIT_CFG {
    alu {
        src {
            src/core/alu.sv
        }
        tb {
            tb/alu/tb_alu.sv
        }
        top tb_alu
    }

    alu_src_a_mux {
        src {
            src/core/alu_src_a_mux.sv
        }
        tb {
            tb/alu_src_a_mux/tb_alu_src_a_mux.sv
        }
        top tb_alu_src_a_mux
    }

    alu_src_b_mux {
        src {
            src/core/alu_src_b_mux.sv
        }
        tb {
            tb/alu_src_b_mux/tb_alu_src_b_mux.sv
        }
        top tb_alu_src_b_mux
    }

    branch_unit {
        src {
            src/core/branch_unit.sv
        }
        tb {
            tb/branch_unit/tb_branch_unit.sv
        }
        top tb_branch_unit
    }

    control_unit {
        src {
            src/core/control_unit.sv
        }
        tb {
            tb/control_unit/utils/tb_utils_pkg.sv
            tb/control_unit/test/tb_control_unit.sv
        }
        top tb_control_unit
    }

    immediate_generator {
        src {
            src/core/immediate_generator.sv
        }
        tb {
            tb/immediate_generator/tb_immediate_generator.sv
        }
        top tb_immediate_generator
    }

    pc_adder {
        src {
            src/core/pc_adder.sv
        }
        tb {
            tb/pc_adder/tb_pc_adder.sv
        }
        top tb_pc_adder
    }

    program_counter {
        src {
            src/core/program_counter.sv
        }
        tb {
            tb/program_counter/tb_program_counter.sv
        }
        top tb_program_counter
    }

    register_file {
        src {
            src/core/register_file.sv
        }
        tb {
            tb/register_file/tb_register_file.sv
        }
        top tb_register_file
    }
}

# Lay danh sach tat ca module
proc get_all_modules {} {
    global UNIT_CFG
    return [array names UNIT_CFG]
}
