# =============================================================================
# run_unit.tcl
# Chay simulation cho 1 unit bat ky, output nam trong sim/<module>/
#
# Cach dung:
#   vsim -c -do "set MODULE alu; source scripts/run_unit.tcl"
#   vsim -c -do "set MODULE control_unit; source scripts/run_unit.tcl"
#
# De xem waveform (co GUI):
#   vsim -do "set MODULE alu; source scripts/run_unit.tcl"
# =============================================================================

# --- Kiem tra bien MODULE co duoc truyen vao khong ---
if {![info exists MODULE]} {
    puts "ERROR: Chua set bien MODULE."
    puts "       Vi du: vsim -c -do \"set MODULE alu; source scripts/run_unit.tcl\""
    quit -code 1
}

# --- Load cau hinh cac unit ---
set SCRIPT_DIR [file dirname [info script]]
set PROJECT_ROOT [file normalize "$SCRIPT_DIR/.."]
source "$SCRIPT_DIR/unit_cfg.tcl"

# --- Kiem tra module co trong config khong ---
if {![info exists UNIT_CFG($MODULE)]} {
    puts "ERROR: Module '$MODULE' khong tim thay trong unit_cfg.tcl"
    puts "       Cac module hop le: [array names UNIT_CFG]"
    quit -code 1
}

# --- Lay thong tin module ---
set cfg      $UNIT_CFG($MODULE)
set src_list [dict get $cfg src]
set tb_list  [dict get $cfg tb]
set top_name [dict get $cfg top]

# --- Tao thu muc output: sim/<module>/ ---
set SIM_DIR "$PROJECT_ROOT/sim/$MODULE"
file mkdir "$SIM_DIR"

# --- Chuyen vao thu muc sim/<module> de work/ va .wlf nam o day ---
cd "$SIM_DIR"

puts "============================================================"
puts " MODULE      : $MODULE"
puts " TOP         : $top_name"
puts " OUTPUT DIR  : $SIM_DIR"
puts "============================================================"

# --- Don dep library cu ---
if {[file exists "work"]} {
    puts ">> Xoa work library cu..."
    vdel -lib work -all
}

# --- Tao library moi ---
vlib work
vmap work work

# --- Compile source files ---
puts "\n>> Compiling source files..."
foreach f $src_list {
    set full_path "$PROJECT_ROOT/$f"
    if {![file exists $full_path]} {
        puts "WARNING: File khong ton tai: $full_path"
        continue
    }
    puts "   vlog: $f"
    vlog -sv -work work \
         +incdir+$PROJECT_ROOT/src/core \
         +incdir+$PROJECT_ROOT/src/memory \
         "$full_path"
}

# --- Compile testbench files ---
puts "\n>> Compiling testbench files..."
foreach f $tb_list {
    set full_path "$PROJECT_ROOT/$f"
    if {![file exists $full_path]} {
        puts "WARNING: File khong ton tai: $full_path"
        continue
    }
    puts "   vlog: $f"
    vlog -sv -work work \
         +incdir+$PROJECT_ROOT/src/core \
         +incdir+$PROJECT_ROOT/src/memory \
         "$full_path"
}

# --- Chay simulation ---
puts "\n>> Starting simulation: work.$top_name"
if {[batch_mode]} {
    # Batch mode (make sim): chay xong tu thoat
	  vsim -t 1ps \
	 -voptargs=+acc \
         -wlf "${MODULE}.wlf" \
         -work work \
         -do "add wave -recursive *; run -all; quit -f" \
         "work.$top_name"
} else {
    # GUI mode (make wave): chay xong KHONG thoat, giu nguyen de xem wave
    vsim -t 1ps \
	 -voptargs=+acc \
         -wlf "${MODULE}.wlf" \
         -work work \
         -do "add wave -recursive *; run -all; wave zoom full" \
         "work.$top_name"
}
