# =============================================================================
# run_top.tcl
# Full-system / top-level simulation script
#
# Cach dung:
#   make sim-top TOP=risc_top
#
# GUI waveform:
#   make wave-top TOP=risc_top
#
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Kiem tra bien TOP
# -----------------------------------------------------------------------------
if {![info exists TOP]} {
    puts "ERROR: Chua set bien TOP."
    puts "       Vi du: make sim-top TOP=risc_top"
    quit -code 1
}

# -----------------------------------------------------------------------------
# 2. Path setup
# -----------------------------------------------------------------------------
set SCRIPT_DIR   [file dirname [info script]]
set PROJECT_ROOT [file normalize "$SCRIPT_DIR/.."]

# -----------------------------------------------------------------------------
# 3. Load top configuration
# -----------------------------------------------------------------------------
source "$SCRIPT_DIR/top_cfg.tcl"

# -----------------------------------------------------------------------------
# 4. Kiem tra TOP co ton tai trong config khong
# -----------------------------------------------------------------------------
if {![info exists TOP_CFG($TOP)]} {
    puts "ERROR: TOP '$TOP' khong ton tai trong top_cfg.tcl"
    puts "       Cac TOP hop le: [array names TOP_CFG]"
    quit -code 1
}

# -----------------------------------------------------------------------------
# 5. Lay thong tin TOP
# -----------------------------------------------------------------------------
set cfg      $TOP_CFG($TOP)

set rtl_list [dict get $cfg src]
set tb_list  [dict get $cfg tb]
set top_name [dict get $cfg top]

# -----------------------------------------------------------------------------
# 6. Tao output directory
# -----------------------------------------------------------------------------
set SIM_DIR "$PROJECT_ROOT/sim/$TOP"

file mkdir $SIM_DIR

# Chuyen vao thu muc output
cd $SIM_DIR

puts "============================================================"
puts " FULL SYSTEM SIMULATION"
puts " TOP MODULE : $TOP"
puts " TESTBENCH  : $top_name"
puts " OUTPUT DIR : $SIM_DIR"
puts "============================================================"

# -----------------------------------------------------------------------------
# 7. Xoa work library cu
# -----------------------------------------------------------------------------
if {[file exists "work"]} {
    puts "\n>> Xoa work library cu..."
    vdel -lib work -all
}

# -----------------------------------------------------------------------------
# 8. Tao work library moi
# -----------------------------------------------------------------------------
vlib work
vmap work work

# -----------------------------------------------------------------------------
# 9. Compile RTL files
# -----------------------------------------------------------------------------
puts "\n>> Compiling RTL files..."

foreach f $rtl_list {

    set full_path "$PROJECT_ROOT/$f"

    if {![file exists $full_path]} {
        puts "ERROR: File khong ton tai:"
        puts "       $full_path"
        quit -code 1
    }

    puts "   vlog: $f"

    if {[catch {

        vlog -sv -work work \
            +incdir+$PROJECT_ROOT/src/core \
            +incdir+$PROJECT_ROOT/src/memory \
            "$full_path"

    } result]} {

        puts ""
        puts "============================================================"
        puts " COMPILE ERROR"
        puts " FILE : $f"
        puts "============================================================"
        puts $result
        puts "============================================================"

        quit -code 1
    }
}

# -----------------------------------------------------------------------------
# 10. Compile testbench files
# -----------------------------------------------------------------------------
puts "\n>> Compiling testbench files..."

foreach f $tb_list {

    set full_path "$PROJECT_ROOT/$f"

    if {![file exists $full_path]} {
        puts "ERROR: File khong ton tai:"
        puts "       $full_path"
        quit -code 1
    }

    puts "   vlog: $f"

    if {[catch {

        vlog -sv -work work \
            +incdir+$PROJECT_ROOT/src/core \
            +incdir+$PROJECT_ROOT/src/memory \
            "$full_path"

    } result]} {

        puts ""
        puts "============================================================"
        puts " TESTBENCH COMPILE ERROR"
        puts " FILE : $f"
        puts "============================================================"
        puts $result
        puts "============================================================"

        quit -code 1
    }
}

# -----------------------------------------------------------------------------
# 11. Start simulation
# -----------------------------------------------------------------------------
puts "\n>> Starting simulation: work.$top_name"

if {[batch_mode]} {

    # Batch mode
    vsim -t 1ps \
         -voptargs=+acc \
         -wlf "${TOP}.wlf" \
         -work work \
         -do "add wave -recursive *; run -all; quit -f" \
         "work.$top_name"

} else {

    # GUI mode
    vsim -t 1ps \
         -voptargs=+acc \
         -wlf "${TOP}.wlf" \
         -work work \
         -do "add wave -recursive *; run -all; wave zoom full" \
         "work.$top_name"
}

