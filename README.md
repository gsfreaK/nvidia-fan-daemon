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

fanSpd=$(( ((gpuTemp - tMin) * (fsMax - fsMin) / (tMax - tMin) + fsMin) + xtrafSpd ))


```bash
#### Control Logic & Threshold Boundaries:
- **Idle State ($T_{\text{gpu}} \le T_{\text{min}}$):** Set manual state to `0` (Allow default driver behavior or 0-RPM fan modes).
- **Linear Region ($T_{\text{min}} < T_{\text{gpu}} < T_{\text{max}}$):** Compute continuous target speed using the formula above and apply state `1` (Manual Override).
- **Critical Thermal Region ($T_{\text{gpu}} \ge T_{\text{max}}$):** Throttle power limits dynamically via `nvidia-smi -pl $pwrLmt -gtt 69` to protect hardware from runaway thermal conditions.

---

## ⚙️ Configuration Variables

Edit the variables at the top of the script according to your GPU thermal targets:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `tMin` | `30` | Minimum temperature threshold (°C) |
| `tMax` | `75` | Maximum temperature threshold (°C) |
| `fsMin` | `30` | Minimum fan duty cycle (%) |
| `fsMax` | `100` | Maximum fan duty cycle (%) |
| `xtrafSpd`| `6` | Safety speed percentage offset |

---

## 🛠️ Installation & Setup

### 1. Requirements
Ensure the NVIDIA proprietary drivers and CLI tools are installed on your system:
- `nvidia-smi`
- `nvidia-settings`

### 2. Copy the Executable
Copy the script to `/usr/local/bin/` and make it executable:
```bash
sudo cp nv-fan-spd-ctrl.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/nv-fan-spd-ctrl.sh

🛠️ Installation & Setup
1. Requirements

Ensure the NVIDIA proprietary drivers and CLI tools are installed on your system:

    nvidia-smi

    nvidia-settings

2. Copy the Executable

Copy the script to /usr/local/bin/ and make it executable:
Bash

sudo cp nv-fan-spd-ctrl.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/nv-fan-spd-ctrl.sh

3. Create the systemd Service

Create the service unit file /etc/systemd/system/nv-fan-spd-ctrl.service with the following content:
Ini, TOML

[Unit]
Description=nVidia Fan Speed Control
After=multi-user.target
Wants=multi-user.target

[Service]
ExecStart=/bin/bash /usr/local/bin/nv-fan-spd-ctrl.sh
Restart=always
TimeoutStopSec=1
KillMode=process

[Install]
WantedBy=multi-user.target

4. Enable and Start the Daemon

Reload the systemd daemon, enable the service to start at boot, and launch it immediately:
Bash

sudo systemctl daemon-reload
sudo systemctl enable --now nv-fan-spd-ctrl.service

📄 License

This project is licensed under the MIT License.
