from pathlib import Path
from vunit import VUnit

VU = VUnit.from_argv()

lib = VU.add_library("lib")

project_dir = Path(__file__).parent
lib.add_source_files(project_dir / "src" / "*.vhd")
lib.add_source_files(project_dir / "src" / "*.vhdl")
lib.add_source_files(project_dir / "tb" / "*.vhdl")

pn9_sequence_path = project_dir / "tb" / "pn9.txt"

VU.set_generic("pn9_sequence_path", pn9_sequence_path)

VU.main()
