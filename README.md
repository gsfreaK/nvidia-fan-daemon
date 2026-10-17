# 🚀 Minimalist NVIDIA Fan & Thermal Control Daemon (Wayland-Compatible)

A lightweight, robust, zero-dependency Bash daemon for dynamic NVIDIA GPU fan control and high-temperature power limit protection on Linux, specifically built to bypass GUI limitations in modern display servers (like Wayland).

---

## 🌟 Key Features

- **Linear Fan Interpolation:** Computes fan speed continuously based on GPU temperature for smooth acoustic transitions.
- **Fail-Safe Power Throttling:** Automatically caps the GPU Power Limit if critical temperatures are reached.
- **Signal Safety (`trap` handler):** Gracefully restores stock NVIDIA driver states (`GPUFanControlState=0`) on exit or unexpected termination signals (`SIGINT`, `SIGTERM`, etc.).
- **Zero-Bloat Execution:** Ultra-low resource footprint using native Bash arithmetic and direct CLI tools (`nvidia-smi` / `nvidia-settings`).
- **`systemd` Ready:** Fully capable of running as a background system daemon.

---

## 📐 Mathematical Formulation

Rather than using step-based fan profiles that cause jarring acoustic jumps, this daemon uses a **1D Linear Interpolation Function** to map the GPU core temperature $T_{\text{gpu}}$ to a precise target fan speed Percentage $S_{\text{fan}}$.

### 1. General Formula

$$S_{\text{fan}} = \left( \frac{T_{\text{gpu}} - T_{\text{min}}}{T_{\text{max}} - T_{\text{min}}} \times (S_{\text{max}} - S_{\text{min}}) \right) + S_{\text{min}} + S_{\text{extra}}$$

Where:
- $T_{\text{gpu}}$ = Current GPU core temperature (°C)
- $T_{\text{min}}$ = Minimum temperature threshold (°C)
- $T_{\text{max}}$ = Maximum temperature threshold (°C)
- $S_{\text{min}}$ = Minimum fan speed (%)
- $S_{\text{max}}$ = Maximum fan speed (%)
- $S_{\text{extra}}$ = Additional user offset speed (%)

---

### 2. Bash Integer Arithmetic Mapping

Because standard Bash shells process integer-only operations, the mathematical expression is ordered to preserve precision prior to division:

```bash
fanSpd=$(( ((gpuTemp - tMin) * (fsMax - fsMin) / (tMax - tMin) + fsMin) + xtrafSpd ))
