# 🔬 Vulnerability Research Pipeline: Fuzzing & Compiler Introspection

[![Docker Build](https://img.shields.io/badge/Docker-Build%20Passing-brightgreen?style=flat&logo=docker)](https://hub.docker.com/)
[![LLVM](https://img.shields.io/badge/LLVM-14.0-blue?style=flat&logo=llvm)](https://llvm.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 📖 Overview

This project demonstrates a **complete vulnerability research pipeline** for C/C++ applications, combining static analysis, runtime instrumentation, and coverage-guided fuzzing.

**The problem it solves:** Identifying security-critical code paths and discovering memory corruption vulnerabilities in real-world software – skills essential for advanced penetration testing and exploit development.

**Key capabilities:**
- **Compiler-based instrumentation** (XRay) to profile function call frequency and latency.
- **Cyclomatic complexity analysis** to pinpoint high-risk, complex code.
- **Coverage-guided fuzzing** (libFuzzer) to automatically generate test cases and find crashes.
- **Code coverage reporting** (gcov/lcov) to measure fuzzing effectiveness.

This repository is a complete, reproducible lab environment – everything you need to repeat the analysis on your own targets.

---

## 🧠 Methodology

### 1. Runtime Profiling with XRay
[LLVM XRay](https://llvm.org/docs/XRay.html) is a function-level tracing framework. By compiling the target with `-fxray-instrument`, we record every function entry/exit during execution. The resulting trace is analysed to identify:
- **Hot functions** (most frequently called)
- **Latency hotspots** (functions with long execution times)

### 2. Static Complexity Analysis
We use `lizard` (a modern cyclomatic complexity analyzer) to calculate the **number of independent paths** through each function. High complexity (> 20) indicates code that is difficult to test and statistically more likely to contain bugs.

### 3. Coverage-Guided Fuzzing
[libFuzzer](https://llvm.org/docs/LibFuzzer.html) is an in-process, coverage-guided fuzzing engine. It generates random inputs, feeds them to the target, and mutates inputs that discover new code paths. Combined with **AddressSanitizer** (ASan) and **UndefinedBehaviorSanitizer** (UBSan), it automatically detects memory corruption and undefined behavior.

### 4. Coverage Analysis
We rebuild the target with `--coverage` (gcov), run the fuzzer-generated corpus, and generate an HTML coverage report with `lcov`. This tells us which parts of the code our fuzzing actually exercised.

---

## 🚀 Quick Start

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) (version 20.10+)
- [Git](https://git-scm.com/downloads)

### 1. Clone the Repository (with Submodules)

The AFL++ source is included as a Git submodule (to keep the main repo lightweight):

```bash
git clone https://github.com/yourusername/Introspection-Fuzzing-Lab.git
cd Introspection-Fuzzing-Lab

```
### 2. Build the Docker Container

The container includes all tools: `Clang/LLVM 14`, `XRay`, `lizard`, `FlameGraph`, `AFL++`, `gcov/lcov`, and `GCC 12`.

```bash
docker build -t fuzzing-lab .
```
This will take few minutes (depends on your network speed). Once finished, verify:

```bash
docker run --rm fuzzing-lab clang --version
```
### 3. Run the Container with Volume Mount

All results generated inside the container will be saved to your host's `./results` folder.

```bash
docker run -it --rm -v $(pwd)/results:/workspace/results fuzzing-lab
```

## 🖥️ Environment Setup: Kali Linux + VSCode Remote

This project is designed to run inside a Docker container. However, to edit files, run commands, and debug interactively, we strongly recommend using **Visual Studio Code** connected to your Kali Linux VM via **Remote - SSH**.

This setup mirrors a professional workflow where the analysis environment (Kali) is isolated from your daily driver (Windows/macOS).

### 1. VirtualBox Network Configuration

Ensure your Kali VM can communicate with your host machine.

- Open **VirtualBox** → Select your Kali VM → **Settings** → **Network**.
- Set **Adapter 1** to **Bridged Adapter** (or **Host-Only + NAT**).
- Start your Kali VM.
### 2. Install and Start the SSH Server on Kali

Open a terminal inside your Kali VM and run:

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh   # Verify it shows "active (running)"
```
### 3. Install the "Remote - SSH" Extension in VSCode
Open Visual Studio Code on your host machine (Windows/macOS/Linux).

Click the Extensions icon (Ctrl+Shift+X) on the left sidebar.

Search for "Remote - SSH" (by Microsoft).

Click Install.
### 4. Connect VSCode to Kali
Press F1 (or Ctrl+Shift+P) to open the command palette.

Type Remote-SSH: Connect to Host... and select it.

Enter: kali@<YOUR_KALI_IP> (e.g., kali@<IP>>).

Select the default SSH configuration file (or press Enter to skip).

When prompted, enter your Kali user password.

VSCode will open a new window. Look for the green indicator in the bottom-left corner showing SSH: 192.168.1.7.

### Troubleshooting: If you receive a "Bad configuration option" error, check your Windows SSH config file at C:\Users\<YourUser>\.ssh\config. Ensure there is no invalid Password line. A minimal working config looks like:
```bash
Host kali-vm
    HostName 192.168.1.7
    User kali
```

### 5. Verify Docker Access from VSCode
Once connected, open a terminal inside VSCode (Terminal → New Terminal). You are now directly shelled into Kali.

Verify Docker is installed and accessible:

```bash
docker --version
```

If Docker is not installed, install it:

```bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```