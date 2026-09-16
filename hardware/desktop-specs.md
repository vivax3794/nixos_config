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
| Model | **AMD Radeon RX 9070** (Navi 48, RDNA4, PCI `1002:7550`, ASUS `1043:061a`) |
| VBIOS | `115-G295BP00-100`, ver `023.008.000.068.000001` (2025/05/07) |
| VRAM | **16304 MiB GDDR6**, 256-bit, mclk 1258 MHz (~20 Gbps, ~640 GB/s) |
| Resizable BAR | enabled - visible VRAM == total VRAM |
| GTT (system-memory spill) | 30940 MiB, half of RAM, reached over PCIe at ~64 GB/s |
| GPU max clock | **2460 MHz** (top sclk DPM state) |
| Power | 317 W cap, 340 W max settable; 3x 8-pin |
| PCIe link | **Gen 5 x16** |
| Dual BIOS switch | currently **P** (performance); Q is the quiet fan curve. Power off to change. |
| Driver | `amdgpu` + Mesa RADV / radeonsi |

> Firmware assigns `boot_vga` to whichever adapter has a display attached at POST.
> With a monitor on the motherboard, the iGPU takes it and niri renders there;
> keeping all displays on this card keeps `boot_vga` here. See the memory note
> `project_gpu_swap_amd`.

## GPU (integrated)

`AMD/ATI Granite Ridge Radeon Graphics` (`1002:13c0`), driver `amdgpu` — present but unused for output (the discrete card drives the display).

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
| PCIE1 | PCIe x16 | x16 mech / **x16 electrical** | `0000:00:01.1` | discrete GPU (Gen5 x16 link) |
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
* Discrete GPU HDMI/DP audio
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
