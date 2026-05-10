def generar_coe(direcciones_datos, archivo_salida):
    with open(archivo_salida, 'w') as coe:
        coe.write("memory_initialization_radix=16;\n")
        coe.write("memory_initialization_vector=\n")

        max_addr = max(direcciones_datos.keys())
        
        for addr in range(max_addr + 1):
            if addr in direcciones_datos:
                dato = direcciones_datos[addr]
            else:
                dato = 0xF  # Puedes poner otro valor por defecto si lo prefieres

            coe.write(f"{dato:04X}")
            if addr < max_addr:
                coe.write(",\n")
            else:
                coe.write(";\n")

# Ejemplo: direcciones específicas con datos
example_code = {
    0: 0x0A,    # ADD 0 + dir 0xA       --> AC = 0x32                   [1]
    1: 0x4B,    # AND 0x32 and dir 0xB  --> AC = 0x32 and 0xE = 0x2     [2]
    2: 0xFF,    # INC 0x2 + 1           --> AC = 0x3                    [3]
    3: 0x8C,    # JMP 0xC                                               [4]
    4: 0xFF,    # INC 0x4 + 1           --> AC = 0x5                    [7]
    10: 0x32,
    11: 0xE,
    12: 0xF1,   # INC 0x3 + 1           --> AC = 0x4                    [5]
    13: 0x84    # JMP 0x4                                               [6]
}

generar_coe(example_code, '../Vivado/basic_CPU/basic_CPU.srcs/sources_1/bd/design_1/ip/design_1_blk_mem_gen_0_0/mem_init.coe')