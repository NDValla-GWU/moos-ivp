#!/bin/bash
#===============================================================================
# MOOS-IvP System Dependencies Installation Script
#===============================================================================
# Description: Automatically installs required system dependencies for 
#              building MOOS-IvP on various Linux distributions
# Author: Nick Valladarez
# Date: September 1, 2025
# Version: 1.0
#
# Supported Distributions:
#   - Ubuntu/Debian (apt)
#   - CentOS/RHEL/Fedora (yum/dnf)
#   - Arch Linux (pacman)
#   - openSUSE (zypper)
#
# Usage:
#   ./install-dependencies.sh [OPTIONS]
#
# Options:
#   --help, -h          Show this help message
#   --minimal, -m       Install minimal dependencies (no GUI components)
#   --dry-run, -n       Show what would be installed without installing
#   --force-distro, -f  Force detection of specific distribution
#                       (ubuntu|debian|centos|fedora|arch|opensuse)
#   --verbose, -v       Enable verbose output
#   --yes, -y           Automatically answer yes to prompts
#
# Examples:
#   ./install-dependencies.sh                    # Full installation
#   ./install-dependencies.sh --minimal          # Minimal installation
#   ./install-dependencies.sh --dry-run          # Preview packages
#   ./install-dependencies.sh --force-distro ubuntu # Force Ubuntu packages
#
# Dependencies installed:
#   Core build tools: g++, cmake, make, git, subversion
#   MOOS essentials: Core libraries and utilities
#   GUI components: FLTK, OpenGL, X11 libraries (unless --minimal)
#   Optional tools: xterm, espeak (text-to-speech)
#
# Exit codes:
#   0 - Success
#   1 - General error
#   2 - Unsupported distribution
#   3 - Permission denied (not running as root/sudo)
#   4 - Package manager not found
#   5 - Package installation failed
#===============================================================================

# Script configuration
SCRIPT_VERSION="1.0"
SCRIPT_NAME="install-dependencies.sh"
LOG_FILE="/tmp/moos-ivp-deps-install.log"

# Default options
MINIMAL_INSTALL=false
DRY_RUN=false
VERBOSE=false
AUTO_YES=false
FORCE_DISTRO=""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#===============================================================================
# Utility Functions
#===============================================================================

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

# Log function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Show help
show_help() {
    cat << EOF
MOOS-IvP System Dependencies Installation Script v$SCRIPT_VERSION

DESCRIPTION:
    Automatically installs required system dependencies for building MOOS-IvP
    on various Linux distributions. Based on requirements documented in
    README-GNULINUX.txt and platform-specific README files.

USAGE:
    $SCRIPT_NAME [OPTIONS]

OPTIONS:
    --help, -h          Show this help message and exit
    --minimal, -m       Install only minimal dependencies (no GUI components)
    --dry-run, -n       Show what would be installed without actually installing
    --force-distro, -f  Force specific distribution detection
                        Valid options: ubuntu, debian, centos, fedora, arch, opensuse
    --verbose, -v       Enable verbose output for debugging
    --yes, -y           Automatically answer yes to all prompts

EXAMPLES:
    $SCRIPT_NAME                           # Full installation with GUI support
    $SCRIPT_NAME --minimal                 # Minimal installation for headless systems
    $SCRIPT_NAME --dry-run                 # Preview what would be installed
    $SCRIPT_NAME --force-distro ubuntu     # Force Ubuntu package names
    $SCRIPT_NAME --verbose --yes           # Verbose output, no prompts

SUPPORTED DISTRIBUTIONS:
    - Ubuntu 16.04+ / Debian 9+
    - CentOS 7+ / RHEL 7+ / Fedora 25+
    - Arch Linux (current)
    - openSUSE Leap 15+

PACKAGES INSTALLED:
    Core Build Tools:
        - g++ (GNU C++ compiler)
        - cmake (cross-platform build system)
        - make (build automation tool)
        - git (version control)
        - subversion (version control)

    MOOS Dependencies:
        - FLTK 1.3+ development files
        - OpenGL/GLUT development files
        - PNG, JPEG, TIFF image libraries
        - X11 extension libraries

    Optional Components (excluded with --minimal):
        - xterm (terminal emulator)
        - espeak (text-to-speech)
        - Additional GUI development libraries

LOG FILE:
    Installation progress and errors are logged to: $LOG_FILE

EXIT CODES:
    0 - Installation completed successfully
    1 - General error occurred
    2 - Unsupported Linux distribution
    3 - Script requires root/sudo privileges
    4 - Package manager not found or not working
    5 - One or more packages failed to install

For more information, see:
    - README-GNULINUX.txt (Linux-specific build instructions)
    - README-OS-X.txt (macOS build instructions)  
    - README-WINDOWS.txt (Windows build instructions)
    - https://moos-ivp.org/ (official documentation)

EOF
}

# Detect Linux distribution
detect_distro() {
    if [ -n "$FORCE_DISTRO" ]; then
        print_verbose "Forcing distribution detection: $FORCE_DISTRO"
        echo "$FORCE_DISTRO"
        return 0
    fi

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu)
                echo "ubuntu"
                ;;
            debian)
                echo "debian"
                ;;
            centos|rhel)
                echo "centos"
                ;;
            fedora)
                echo "fedora"
                ;;
            arch|manjaro)
                echo "arch"
                ;;
            opensuse|opensuse-leap|opensuse-tumbleweed)
                echo "opensuse"
                ;;
            *)
                print_warning "Unknown distribution ID: $ID"
                echo "unknown"
                ;;
        esac
    elif [ -f /etc/redhat-release ]; then
        echo "centos"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/SuSE-release ]; then
        echo "opensuse"
    else
        print_warning "Cannot detect Linux distribution"
        echo "unknown"
    fi
}

# Check if running with sufficient privileges
check_privileges() {
    if [ "$EUID" -ne 0 ] && ! command -v sudo >/dev/null 2>&1; then
        print_error "This script requires root privileges or sudo access"
        print_error "Please run with sudo or as root user"
        exit 3
    fi
}

# Get package manager command prefix
get_package_manager_cmd() {
    local distro="$1"
    
    if [ "$EUID" -eq 0 ]; then
        local sudo_cmd=""
    else
        local sudo_cmd="sudo"
    fi

    case "$distro" in
        ubuntu|debian)
            echo "$sudo_cmd apt-get"
            ;;
        centos)
            if command -v dnf >/dev/null 2>&1; then
                echo "$sudo_cmd dnf"
            else
                echo "$sudo_cmd yum"
            fi
            ;;
        fedora)
            echo "$sudo_cmd dnf"
            ;;
        arch)
            echo "$sudo_cmd pacman"
            ;;
        opensuse)
            echo "$sudo_cmd zypper"
            ;;
        *)
            print_error "Unsupported distribution: $distro"
            exit 2
            ;;
    esac
}

#===============================================================================
# Package Definitions
#===============================================================================

# Core packages required for all installations
get_core_packages() {
    local distro="$1"
    
    case "$distro" in
        ubuntu|debian)
            echo "build-essential cmake git subversion g++"
            ;;
        centos|fedora)
            echo "gcc-c++ cmake git subversion make"
            ;;
        arch)
            echo "base-devel cmake git subversion gcc"
            ;;
        opensuse)
            echo "gcc-c++ cmake git subversion make"
            ;;
    esac
}

# MOOS-specific packages (as documented in README-GNULINUX.txt)
get_moos_packages() {
    local distro="$1"
    
    case "$distro" in
        ubuntu|debian)
            echo "libfltk1.3-dev freeglut3-dev libpng-dev libjpeg-dev libxft-dev libxinerama-dev libtiff5-dev"
            ;;
        centos|fedora)
            echo "fltk-devel freeglut-devel libpng-devel libjpeg-turbo-devel libXft-devel libXinerama-devel libtiff-devel"
            ;;
        arch)
            echo "fltk freeglut libpng libjpeg-turbo libxft libxinerama libtiff"
            ;;
        opensuse)
            echo "fltk-devel freeglut-devel libpng16-devel libjpeg8-devel libXft-devel libXinerama-devel libtiff-devel"
            ;;
    esac
}

# GUI packages (excluded in minimal installation)
get_gui_packages() {
    local distro="$1"
    
    if [ "$MINIMAL_INSTALL" = true ]; then
        echo ""
        return
    fi
    
    case "$distro" in
        ubuntu|debian)
            echo "xterm espeak xorg-dev libglu1-mesa-dev libgl1-mesa-dev libxpm-dev"
            ;;
        centos|fedora)
            echo "xterm espeak mesa-libGLU-devel mesa-libGL-devel libXpm-devel xorg-x11-server-devel"
            ;;
        arch)
            echo "xterm espeak glu mesa libxpm xorg-server-devel"
            ;;
        opensuse)
            echo "xterm espeak glu-devel Mesa-libGL-devel libXpm-devel xorg-x11-server-sdk"
            ;;
    esac
}

#===============================================================================
# Installation Functions
#===============================================================================

# Update package manager cache
update_package_cache() {
    local distro="$1"
    local pkg_cmd="$2"
    
    print_info "Updating package manager cache..."
    log_message "Updating package cache for $distro"
    
    if [ "$DRY_RUN" = true ]; then
        print_verbose "DRY RUN: Would run: $pkg_cmd update"
        return 0
    fi
    
    case "$distro" in
        ubuntu|debian)
            $pkg_cmd update
            ;;
        centos|fedora)
            # dnf/yum update cache automatically
            true
            ;;
        arch)
            $pkg_cmd -Sy
            ;;
        opensuse)
            $pkg_cmd refresh
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        print_success "Package cache updated successfully"
    else
        print_warning "Package cache update failed, continuing anyway"
    fi
}

# Install packages
install_packages() {
    local distro="$1"
    local pkg_cmd="$2"
    local packages="$3"
    local category="$4"
    
    if [ -z "$packages" ]; then
        print_verbose "No $category packages to install"
        return 0
    fi
    
    print_info "Installing $category packages: $packages"
    log_message "Installing $category packages: $packages"
    
    if [ "$DRY_RUN" = true ]; then
        print_verbose "DRY RUN: Would install: $packages"
        return 0
    fi
    
    # Prepare install command based on distribution
    local install_cmd
    local auto_yes_flag=""
    
    if [ "$AUTO_YES" = true ]; then
        case "$distro" in
            ubuntu|debian)
                auto_yes_flag="-y"
                ;;
            centos|fedora)
                auto_yes_flag="-y"
                ;;
            arch)
                auto_yes_flag="--noconfirm"
                ;;
            opensuse)
                auto_yes_flag="-y"
                ;;
        esac
    fi
    
    case "$distro" in
        ubuntu|debian)
            install_cmd="$pkg_cmd install $auto_yes_flag $packages"
            ;;
        centos|fedora)
            install_cmd="$pkg_cmd install $auto_yes_flag $packages"
            ;;
        arch)
            install_cmd="$pkg_cmd -S $auto_yes_flag $packages"
            ;;
        opensuse)
            install_cmd="$pkg_cmd install $auto_yes_flag $packages"
            ;;
    esac
    
    print_verbose "Running: $install_cmd"
    
    if ! $install_cmd; then
        print_error "Failed to install $category packages"
        log_message "ERROR: Failed to install $category packages"
        return 1
    else
        print_success "$category packages installed successfully"
        log_message "SUCCESS: $category packages installed"
        return 0
    fi
}

#===============================================================================
# Main Installation Logic
#===============================================================================

main_install() {
    local distro
    local pkg_cmd
    local core_packages
    local moos_packages  
    local gui_packages
    local failed_categories=0
    
    print_info "Starting MOOS-IvP dependencies installation..."
    log_message "=== MOOS-IvP Dependencies Installation Started ==="
    log_message "Script version: $SCRIPT_VERSION"
    log_message "Options: MINIMAL_INSTALL=$MINIMAL_INSTALL, DRY_RUN=$DRY_RUN, VERBOSE=$VERBOSE, AUTO_YES=$AUTO_YES"
    
    # Detect distribution
    distro=$(detect_distro)
    if [ "$distro" = "unknown" ]; then
        print_error "Unsupported Linux distribution"
        print_error "Supported distributions: Ubuntu, Debian, CentOS, RHEL, Fedora, Arch Linux, openSUSE"
        print_error "Use --force-distro option to override detection"
        exit 2
    fi
    
    print_info "Detected distribution: $distro"
    log_message "Detected distribution: $distro"
    
    # Get package manager command
    pkg_cmd=$(get_package_manager_cmd "$distro")
    print_verbose "Package manager command: $pkg_cmd"
    
    # Verify package manager is available
    local base_pkg_mgr=$(echo "$pkg_cmd" | awk '{print $NF}')
    if ! command -v "$base_pkg_mgr" >/dev/null 2>&1; then
        print_error "Package manager '$base_pkg_mgr' not found"
        exit 4
    fi
    
    # Get package lists
    core_packages=$(get_core_packages "$distro")
    moos_packages=$(get_moos_packages "$distro")
    gui_packages=$(get_gui_packages "$distro")
    
    print_info "Installation plan:"
    print_info "  Core packages: $core_packages"
    print_info "  MOOS packages: $moos_packages"
    if [ "$MINIMAL_INSTALL" = true ]; then
        print_info "  GUI packages: (skipped - minimal installation)"
    else
        print_info "  GUI packages: $gui_packages"
    fi
    
    if [ "$DRY_RUN" = true ]; then
        print_warning "DRY RUN MODE: No packages will actually be installed"
    fi
    
    # Confirm installation if not auto-yes
    if [ "$AUTO_YES" != true ] && [ "$DRY_RUN" != true ]; then
        echo
        read -p "Proceed with installation? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled by user"
            exit 0
        fi
    fi
    
    # Update package cache
    update_package_cache "$distro" "$pkg_cmd"
    
    # Install packages by category
    echo
    print_info "Installing packages..."
    
    # Core build tools
    if ! install_packages "$distro" "$pkg_cmd" "$core_packages" "core build tools"; then
        ((failed_categories++))
    fi
    
    # MOOS-specific libraries
    if ! install_packages "$distro" "$pkg_cmd" "$moos_packages" "MOOS libraries"; then
        ((failed_categories++))
    fi
    
    # GUI packages (unless minimal install)
    if [ "$MINIMAL_INSTALL" != true ]; then
        if ! install_packages "$distro" "$pkg_cmd" "$gui_packages" "GUI components"; then
            ((failed_categories++))
        fi
    fi
    
    # Installation summary
    echo
    print_info "=== Installation Summary ==="
    if [ "$DRY_RUN" = true ]; then
        print_info "DRY RUN completed - no packages were actually installed"
    elif [ $failed_categories -eq 0 ]; then
        print_success "All package categories installed successfully!"
        print_info "You can now build MOOS-IvP with: ./build.sh"
        log_message "SUCCESS: All packages installed successfully"
    else
        print_warning "$failed_categories package categories failed to install"
        print_warning "Check the log file for details: $LOG_FILE"
        print_warning "You may need to install missing packages manually"
        log_message "WARNING: $failed_categories package categories failed"
        exit 5
    fi
    
    # Next steps information
    if [ "$DRY_RUN" != true ] && [ $failed_categories -eq 0 ]; then
        echo
        print_info "=== Next Steps ==="
        print_info "1. Build MOOS-IvP: ./build.sh"
        print_info "2. Verify build: ./build-check.sh"
        print_info "3. Add to PATH: export PATH=\$PATH:$(pwd)/bin"
        print_info ""
        print_info "For detailed build instructions, see:"
        print_info "  - BUILD_FIXES_SUMMARY.txt"
        print_info "  - README-GNULINUX.txt"
        print_info "  - CLONE_AND_BUILD_INSTRUCTIONS.txt"
    fi
    
    log_message "=== Installation completed ==="
}

#===============================================================================
# Command Line Argument Processing
#===============================================================================

# Process command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --minimal|-m)
            MINIMAL_INSTALL=true
            shift
            ;;
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --force-distro|-f)
            FORCE_DISTRO="$2"
            if [ -z "$FORCE_DISTRO" ]; then
                print_error "Option --force-distro requires a distribution name"
                exit 1
            fi
            shift 2
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            print_error "Use --help for usage information"
            exit 1
            ;;
    esac
done

#===============================================================================
# Script Execution
#===============================================================================

# Initialize log file
echo "=== MOOS-IvP Dependencies Installation Log ===" > "$LOG_FILE"
echo "Started: $(date)" >> "$LOG_FILE"

# Check privileges (unless dry run)
if [ "$DRY_RUN" != true ]; then
    check_privileges
fi

# Run main installation
main_install

# Clean up and exit
exit 0
