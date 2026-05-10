from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]

VIVADO_PROJECT = ROOT / "Vivado" / "basic_CPU"

# Orígenes
SRC_MEMORY = ROOT / "memory"
SRC_HDL = VIVADO_PROJECT / "basic_CPU.srcs" / "sources_1" / "new"
SRC_BD = VIVADO_PROJECT / "design_1.tcl"
SRC_CONSTRAINTS = VIVADO_PROJECT / "basic_CPU.srcs" / "constrs_1" / "new"
SRC_IPS = VIVADO_PROJECT / "basic_CPU.srcs" / "sources_1" / "ip"

SRC_SIM_1 = VIVADO_PROJECT / "basic_CPU.srcs" / "sim_1" / "new"
SRC_SIM_2 = VIVADO_PROJECT / "sim_1" / "new"

SRC_WCFG = VIVADO_PROJECT / "sim_CPU_behav.wcfg"

# Destinos limpios del repo
DEST_MEMORY = ROOT / "memory"
DEST_HDL = ROOT / "hdl"
DEST_BD = ROOT / "bd"
DEST_CONSTRAINTS = ROOT / "constraints"
DEST_IPS = ROOT / "ips"
DEST_SIM = ROOT / "simulation"
DEST_SCRIPTS = ROOT / "scripts"


def same_path(a: Path, b: Path) -> bool:
    try:
        return a.resolve() == b.resolve()
    except FileNotFoundError:
        return a.absolute() == b.absolute()


def copy_file(src: Path, dst_dir: Path):
    if not src.exists() or not src.is_file():
        print(f"[SKIP] No existe fichero: {src}")
        return

    dst_dir.mkdir(parents=True, exist_ok=True)
    target = dst_dir / src.name

    if same_path(src, target):
        print(f"[SKIP] Origen y destino son el mismo fichero: {src}")
        return

    shutil.copy2(src, target)
    print(f"[OK] Fichero copiado: {src} -> {target}")


def copy_dir(src: Path, dst: Path):
    if not src.exists() or not src.is_dir():
        print(f"[SKIP] No existe directorio: {src}")
        return

    if same_path(src, dst):
        print(f"[SKIP] Origen y destino son el mismo directorio: {src}")
        return

    dst.mkdir(parents=True, exist_ok=True)

    for item in src.iterdir():
        target = dst / item.name

        if same_path(item, target):
            print(f"[SKIP] Origen y destino son el mismo elemento: {item}")
            continue

        if item.is_dir():
            shutil.copytree(item, target, dirs_exist_ok=True)
            print(f"[OK] Directorio copiado: {item} -> {target}")
        else:
            shutil.copy2(item, target)
            print(f"[OK] Fichero copiado: {item} -> {target}")


def main():
    print(f"Raíz del repo: {ROOT}")

    copy_dir(SRC_MEMORY, DEST_MEMORY)
    copy_dir(SRC_HDL, DEST_HDL)
    copy_file(SRC_BD, DEST_BD)
    copy_dir(SRC_CONSTRAINTS, DEST_CONSTRAINTS)
    copy_dir(SRC_IPS, DEST_IPS)

    if SRC_SIM_1.exists():
        copy_dir(SRC_SIM_1, DEST_SIM)
    elif SRC_SIM_2.exists():
        copy_dir(SRC_SIM_2, DEST_SIM)
    else:
        print("[SKIP] No se encontró carpeta de simulación.")

    copy_file(SRC_WCFG, DEST_SIM)

    DEST_SCRIPTS.mkdir(parents=True, exist_ok=True)
    print(f"[OK] Carpeta scripts preparada: {DEST_SCRIPTS}")

    print("\nProceso terminado.")


if __name__ == "__main__":
    main()