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
git clone --recursive https://github.com/Anub1s1999/Introspection-Fuzzing-Lab.git
cd Introspection-Fuzzing-Lab

