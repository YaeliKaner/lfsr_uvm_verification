# LFSR Design and UVM Verification Environment

## Overview
This repository contains a complete hardware design and verification environment for a Linear Feedback Shift Register (LFSR). The design is written in SystemVerilog, and the verification environment is built from scratch using the **UVM (Universal Verification Methodology)** standard.

## Verification Architecture
The UVM testbench is structured to ensure comprehensive functional coverage and robust verification of the LFSR logic:
* **UVM Agent:** Includes Sequencer, Driver, and Monitor.
* **Scoreboard:** Validates the LFSR output against a behavioral golden model.
* **Coverage Collector:** Tracks functional and code coverage to ensure all states and feedback polynomial combinations are fully verified.

## Repository Structure
* `/rtl`: Contains the SystemVerilog source code for the LFSR design.
* `/verif`: Contains the UVM testbench components (env, agents, sequences, tests, and scoreboard).
* `/run`: Contains scripts, Makefiles, and simulation configurations.

## How to Run
To run the simulation, navigate to the `run` directory and execute:
```bash
make run
