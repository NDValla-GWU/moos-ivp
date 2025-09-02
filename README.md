# MOOS-IvP

[![Build Status](https://github.com/NDValla-GWU/moos-ivp/workflows/MOOS-IvP%20Build%20and%20Test/badge.svg)](https://github.com/NDValla-GWU/moos-ivp/actions)
[![Quick CI](https://github.com/NDValla-GWU/moos-ivp/workflows/Quick%20CI/badge.svg)](https://github.com/NDValla-GWU/moos-ivp/actions)

[MOOS-IvP](https://moos-ivp.org/) is a set of open source C++ modules for providing autonomy on robotic platforms, in particular autonomous marine vehicles.

## Quick Start

### Automated Installation (Recommended)
```bash
# Clone repository
git clone https://github.com/NDValla-GWU/moos-ivp.git
cd moos-ivp

# Install dependencies automatically (Linux)
./install-dependencies.sh

# Build everything
./build.sh

# Verify build
./build-check.sh
```

### Manual Installation
See [CLONE_AND_BUILD_INSTRUCTIONS.txt](./CLONE_AND_BUILD_INSTRUCTIONS.txt) for detailed setup instructions.

## Build Status and Automation

This repository includes automated CI/CD workflows that:
- **Multi-Platform Builds**: Ubuntu 20.04, 22.04, Rocky Linux 8
- **Automated Testing**: Build verification and unit tests
- **Dependency Management**: Weekly compatibility checks
- **Security Scanning**: Vulnerability detection
- **Release Automation**: Automatic package generation

See [.github/workflows/README.md](./.github/workflows/README.md) for detailed CI/CD documentation.

## Documentation

- **Quick Reference**: [BUILD_FIXES_SUMMARY.txt](./BUILD_FIXES_SUMMARY.txt)
- **Complete Setup Guide**: [CLONE_AND_BUILD_INSTRUCTIONS.txt](./CLONE_AND_BUILD_INSTRUCTIONS.txt)
- **Technical Details**: [BUILD_FIXES_DOCUMENTATION.txt](./BUILD_FIXES_DOCUMENTATION.txt)
- **CI/CD Information**: [.github/workflows/README.md](./.github/workflows/README.md)

## Project Objectives and Philosophy

* Platform Independence: The MOOS-IvP software typically runs on a dedicated computer for autonomy and sensing in the vehicle "payload" section.

* Module Independence: MOOS and the IvP Helm provide two architectures that enable the autonomy and sensing system to be built from distinct and independent modules.

* Nested Capabilities: MOOS and IvP Helm architectures both allow a system to be extended without any modifying or recompiling the core, publicly available free software.

## Project Organization

The project is situated at MIT, in the Department of Mechanical Engineering and the Center for Ocean Engineering as part of the Laboratory for Autonomous Marine Sensing Systems (LAMSS). Core developers are also part of the MIT Computer Science and Artificial Intelligence Lab, (CSAIL). Core MOOS software is maintained and distributed by the Oxford Robotics Institute (ORI).

MOOS stands for "Mission Oriented Operating Suite". IvP stands for "Interval Programming". MOOS-IvP is pronounced "moose i-v-p".

## Contributing and Licensing

We welcome contributions to MOOS-IvP! Please reference our [contribution policy](./CONTRIBUTING.md) and CLA for more details.

The MOOS and MOOS-IvP codebases are licensed under a mix of GPLv3, LGPLv3, and optionally, a commercial license. Please reference [COPYING.md](./COPYING.md) for more details.
