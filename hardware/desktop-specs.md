# Desktop Hardware Specification

Generated: 2026-05-15
Host: `desktop`
OS: NixOS 26.05 "Yarara" — kernel 7.0.3

## CPU

| Field | Value |
|---|---|
| Model | **AMD Ryzen 9 9950X3D** (Granite Ridge, Zen 5, family 26 model 68 stepping 0) |
| Microcode | `0xb404035` |
| Topology | 1 socket × 16 cores × 2 threads = **32 logical CPUs** |
| Base clock | ~4.3 GHz (BogoMIPS 8583.34) |
| Max boost | **5756.45 MHz** |
| Min freq | 624.19 MHz |
| Frequency boost | enabled |
| Scaling driver | `amd-pstate-epp` |
| Governor / EPP | `performance` / `performance` |
| Virtualisation | AMD-V (SVM, NPT, x2AVIC, etc.) |
| Address width | 48-bit physical / 48-bit virtual |
| NUMA | single node (CPUs 0–31) |

### Cache (line size 64 B throughout)

| Level | Size | Notes |
|---|---|---|
| L1d | 48 KiB ×16 = 768 KiB total | per-core |
| L1i | 32 KiB ×16 = 512 KiB total | per-core |
| L2 | 1 MiB ×16 = 16 MiB total | per-core |
| L3 | 128 MiB across 2 CCDs (96 MiB visible per core, 64 MiB 3D V-Cache stacked on one CCD) | shared per CCX |

### Notable ISA features

`avx512f/dq/bw/cd/vl/ifma/vbmi/vbmi2/vnni/bitalg/vpopcntdq/bf16/vp2intersect`, `sha_ni`, `gfni`, `vaes`, `vpclmulqdq`, `amx`-class via `avx_vnni`, `rdrand`/`rdseed`, `pku`/`ospke`, `user_shstk` (CET-SS), `movdiri`/`movdir64b`.

## Memory

| Field | Value |
|---|---|
| Total installed | **64 GiB** (2× 32 GiB, ~60 GiB visible to Linux after reservations) |
| Type | **DDR5**, Unbuffered, non-ECC |
| Speed | **6000 MT/s** (configured = SPD/EXPO programmed; matches kit SKU) |
| Voltage | 1.1 V configured (1.1 V min/max per SPD) |
| Module | **Kingston FURY `KF560C30-32`** — DDR5-6000 CL30, 32 GiB, dual-rank |
| Module mfr ID | Bank 2 / `0x98` (Kingston) |
| Channels | dual-channel, 64-bit data width per DIMM |
| Slots populated | DIMM 1 of `P0 CHANNEL A` (S/N `D10CE42E`) + DIMM 1 of `P0 CHANNEL B` (S/N `D00CE1CD`) |
| Slots free | DIMM 0 of A and DIMM 0 of B (2× empty) |
| Max board capacity | **128 GiB** across 4 slots |
| Swap | 15.1 GiB **zram** (`/dev/zram0`, no disk swap) |

> EXPO at 6000 MT/s + C-state interaction is the known instability vector on this board — see `project_bios_hang_incident.md`.

## GPU (discrete)

| Field | Value |
|---|---|
| Model | **NVIDIA GeForce RTX 5060** (GB206, Blackwell, PCI `10de:2d05`) |
| Board vendor | InnoVISION (Inno3D) |
| VBIOS | `98.06.21.40.B8` |
| VRAM | **8 GiB** (8151 MiB usable, GDDR7) |
| BAR1 | 8 GiB |
| Memory clock | up to **14 001 MHz** (effective 28 Gbps GDDR7); idle 7001 MHz |
| GPU max clock | **3090 MHz** (SM/graphics/video) |
| Power | default 145 W (123 W min, 145 W max) |
| Driver | NVIDIA proprietary 595.45.04, CUDA 13.2 runtime |
| Display | enabled, current temp ~40 °C, T.limit 50 °C |
| PCIe link | Gen 5, currently **x8** (board/slot wired x8) |

## GPU (integrated)

`AMD/ATI Granite Ridge Radeon Graphics` (`1002:13c0`), driver `amdgpu` — present but currently unused for output (NVIDIA drives the display).

## Storage

| Field | Value |
|---|---|
| Drive | **Samsung SSD 9100 PRO 1 TB** (`PM9E1`, firmware `0B2QNXH7`) |
| Serial | `S7YDNJ0Y301552W` |
| Interface | NVMe, **PCIe Gen 5 x4** (`02:00.0`) |
| Capacity | 931.5 GiB (1 TB) |
| Logical / physical block | 512 / 512 B |
| Queue depth | 1023 |
| `max_hw_sectors_kb` | 128 |
| Scheduler | `[none]` (mq-deadline, kyber available) |
| Rotational | no |

### Partitions

```
nvme0n1     931.5 G
├─nvme0n1p1   1 G    vfat   /boot
└─nvme0n1p2 930.5 G  ext4   /
```

## Motherboard / Platform Firmware

| Field | Value |
|---|---|
| Board | **Gigabyte X870E AORUS PRO ICE** (Family "X870E MB") |
| Socket | AM5 |
| BIOS | AMI **FA9** (02/05/2026), 32 MiB ROM, UEFI |
| AGESA | `V9 ComboAm5PI 1.2.8.0` |
| Platform Firmware rev | 5.41 |
| TPM | **AMD fTPM 2.0** (firmware 6.32) |
| Audio codec on board | Realtek ALC1220 |

### Expansion slots in use

| Slot | Type | Width | Bus addr | Occupant |
|---|---|---|---|---|
| PCIE1 | PCIe x16 | x16 mech / **x8 electrical now** | `0000:00:01.1` | RTX 5060 (Gen5 x8 link) |
| J3502 | M.2 Socket 3 | x4 | `0000:00:01.2` | Samsung 9100 PRO NVMe (Gen5 x4) |
| PCIE3 | PCIe x4 | x4 | `0000:00:02.2` | (occupied — likely chipset-attached) |

### Chipset & on-die

* Root complex: AMD Raphael/Granite Ridge (`1022:14d8`)
* Chipset: AMD 800-series promontory pair via ASMedia bridges (`1022:43f4/43f5`)
* IT87 sensor chip patched into kernel via `it87-patch.nix`

### External port headers (DMI)

* 3× USB-C (J1500/J1501/J1502)
* 1× USB 2.0, 1× USB 3.2 (rear)
* "Nova" video header (J1100) — likely the iGPU DP/HDMI output
* Front-audio, rear-audio, HD-audio HDR (mini-jack)

## Networking

| Iface | Detail |
|---|---|
| `enp14s0` | Realtek **RTL8125 2.5 GbE** (`10ec:8125`), MAC `10:ff:e0:c7:06:4d` |
| Negotiated | **1000 Mb/s full-duplex** (link partner only advertises up to 1 G) |
| Driver | `r8169` |

No wireless adapter present.

## USB / Thunderbolt

* **ASM4242 USB4 / Thunderbolt 3** host router (`1b21:2425`, `thunderbolt` driver)
* ASMedia ASM4242 USB 3.2 xHCI (`1b21:2426`)
* Multiple AMD 800-series chipset USB 3.x xHCI controllers (`1022:43fd`)
* AMD Raphael USB 3.1 + USB 2.0 xHCI on-die controllers

## Audio

* **Realtek ALC1220** (HDA, board-tagged `1022:15e3`)
* NVIDIA GB206 HDMI/DP audio (`10de:22eb`)
* AMD Radeon HD-audio on iGPU (`1002:1640`)

## Other on-board

* AMD PSP/CCP encryption engine (`1022:1649`, driver `ccp`) — hardware RNG / crypto offload
* SATA: 2× AMD 600-series AHCI controllers exposed; no rotational drives currently attached
* SMBus + LPC bridge for sensors (k10temp + it87)

## Software environment

* NixOS 26.05.20260505.549bd84 ("Yarara")
* Kernel **7.0.3** (`PREEMPT_DYNAMIC`, NixOS build)
* WM: Niri (Wayland)
* Display server: native Wayland + Xwayland shim
