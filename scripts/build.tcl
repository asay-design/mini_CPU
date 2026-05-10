# ============================================================
# build.tcl
# Reconstruye el proyecto Vivado desde la estructura limpia
# ============================================================

set script_dir [file dirname [file normalize [info script]]]
set repo_dir   [file normalize [file join $script_dir ".."]]

set project_name "basic_CPU_rebuilt"
set build_dir    [file join $repo_dir "vivado_build"]

# CAMBIA ESTO POR TU FPGA REAL
set part_name "xc7a35tcpg236-1"

puts "Repo dir: $repo_dir"
puts "Build dir: $build_dir"

create_project $project_name $build_dir -part $part_name -force

# ============================================================
# Añadir HDL propio
# ============================================================

set hdl_dir [file join $repo_dir "hdl"]

if {[file exists $hdl_dir]} {
    set hdl_files [glob -nocomplain \
        [file join $hdl_dir "*.vhd"] \
        [file join $hdl_dir "*.vhdl"] \
        [file join $hdl_dir "*.v"] \
        [file join $hdl_dir "*.sv"]]

    if {[llength $hdl_files] > 0} {
        add_files -fileset sources_1 $hdl_files
    }
}

# ============================================================
# Añadir constraints
# ============================================================

set constr_dir [file join $repo_dir "constraints"]

if {[file exists $constr_dir]} {
    set xdc_files [glob -nocomplain [file join $constr_dir "*.xdc"]]

    if {[llength $xdc_files] > 0} {
        add_files -fileset constrs_1 $xdc_files
    }
}

# ============================================================
# Añadir testbenches
# ============================================================

set sim_dir [file join $repo_dir "simulation"]

if {[file exists $sim_dir]} {
    set sim_files [glob -nocomplain \
        [file join $sim_dir "*.vhd"] \
        [file join $sim_dir "*.vhdl"] \
        [file join $sim_dir "*.v"] \
        [file join $sim_dir "*.sv"]]

    if {[llength $sim_files] > 0} {
        add_files -fileset sim_1 $sim_files
    }
}

# ============================================================
# Añadir IPs propias, si existen
# ============================================================

set ip_dir [file join $repo_dir "IPs"]

if {[file exists $ip_dir]} {
    set ip_repo_paths [glob -nocomplain -type d [file join $ip_dir "*"]]

    if {[llength $ip_repo_paths] > 0} {
        set_property ip_repo_paths $ip_repo_paths [current_project]
        update_ip_catalog
    }
}

# ============================================================
# Crear Block Design desde TCL
# ============================================================

set bd_tcl [file join $repo_dir "BD" "design_1.tcl"]

if {[file exists $bd_tcl]} {
    source $bd_tcl
} else {
    puts "ERROR: No se encontró el TCL del BD: $bd_tcl"
    exit 1
}

# ============================================================
# Reasignar fichero COE si hace falta
# ============================================================
# Ajusta el nombre blk_mem_gen_0 si tu instancia se llama diferente.

set coe_file [file join $repo_dir "Memory" "programa.coe"]

if {[file exists $coe_file]} {
    if {[llength [get_bd_cells -quiet blk_mem_gen_0]] > 0} {
        set_property -dict [list CONFIG.Coe_File $coe_file] [get_bd_cells blk_mem_gen_0]
        puts "COE asignado a blk_mem_gen_0: $coe_file"
    } else {
        puts "Aviso: no se encontró blk_mem_gen_0. Revisa el nombre de la IP de memoria."
    }
} else {
    puts "Aviso: no se encontró programa.coe en Memory/"
}

# ============================================================
# Validar BD y generar productos
# ============================================================

validate_bd_design
save_bd_design

generate_target all [get_files *.bd]

# ============================================================
# Crear wrapper HDL del BD
# ============================================================

set bd_files [get_files *.bd]

make_wrapper -files $bd_files -top
set wrapper_files [glob -nocomplain [file join $build_dir $project_name.gen "sources_1" "bd" "*" "hdl" "*_wrapper.vhd"]]

if {[llength $wrapper_files] == 0} {
    set wrapper_files [glob -nocomplain [file join $build_dir $project_name.gen "sources_1" "bd" "*" "hdl" "*_wrapper.v"]]
}

if {[llength $wrapper_files] > 0} {
    add_files -norecurse $wrapper_files
} else {
    puts "Aviso: no se encontró wrapper generado."
}

# ============================================================
# Restaurar waveform, si existe
# ============================================================

set wcfg_file [file normalize [file join $repo_dir "simulation" "sim_CPU_behav.wcfg"]]

if {[file exists $wcfg_file]} {
    puts "Adding waveform config: $wcfg_file"
    add_files -fileset sim_1 [list $wcfg_file]
} else {
    puts "Waveform config not found: $wcfg_file"
}

# ============================================================
# Actualizar orden de compilación
# ============================================================

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

save_project

puts "Proyecto reconstruido correctamente."