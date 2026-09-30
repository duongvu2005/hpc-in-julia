# HPC in Julia

Code and experiments while following Jamie Mair's
[High Performance Computing in Julia](https://youtube.com/playlist?list=PLUAq6xQKFgGr39PiyrPk_C9dhBKvWcjUA)
lecture series.

## Setup

Requires [pixi](https://pixi.sh). Works on Windows (`win-64`) and macOS (`osx-arm64`).

```bash
pixi install     # installs Julia
pixi run setup   # installs the Julia packages from Manifest.toml
pixi run repl    # Julia REPL with the project active, one thread per core
```

## Tasks

| Task             | What it does                        |
| ---------------- | ----------------------------------- |
| `pixi run setup` | `Pkg.instantiate()` for the project |
| `pixi run repl`  | REPL with `--threads=auto`          |

Run a demo file:

```bash
pixi run julia --project=. --threads=auto demos/<topic>/<file>.jl
```

Use `--threads=1` for benchmarks that need a serial baseline.

## Layout

```
demos/      one folder per topic, one file per idea
scripts/    job scripts (e.g. SLURM)
```

## Notes

- Julia packages are managed by Pkg (`Project.toml`, `Manifest.toml`); pixi only provides the toolchain.
- GPU demos (CUDA.jl) need an NVIDIA GPU and won't run on macOS.
