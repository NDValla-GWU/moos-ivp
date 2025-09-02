# MOOS-IvP GitHub Actions CI/CD

This directory contains GitHub Actions workflows that automate various aspects of the MOOS-IvP build and development process.

## Workflows Overview

### 1. `build-and-test.yml` - Comprehensive Build and Test
**Triggers**: Push to main/develop, Pull Requests, Manual dispatch
**Purpose**: Full CI/CD pipeline with multi-platform builds

**Features**:
- **Multi-Platform Support**: Ubuntu 20.04, 22.04 + Rocky Linux 8
- **Multi-Configuration**: Release and Debug builds
- **Automated Dependencies**: Uses `install-dependencies.sh`
- **Build Verification**: Runs `build-check.sh` to ensure completeness
- **Artifact Generation**: Creates release-ready packages
- **Basic Static Analysis**: cppcheck, clang-format, shellcheck
- **Security Scanning**: Trivy vulnerability scanner
- **Automatic Releases**: Creates GitHub releases for tagged versions

**Artifacts Produced**:
- `moos-ivp-ubuntu-22.04.tar.gz` - Complete build package
- `basic-analysis-results/` - Basic static analysis reports
- Security scan results (SARIF format)

### 2. `enhanced-static-analysis.yml` - Comprehensive Code Quality
**Triggers**: Push to main/develop, Pull Requests, Weekly schedule, Manual dispatch
**Purpose**: Thorough code quality, security, and compliance analysis

**Features**:
- **Code Quality Analysis**: cppcheck, clang-tidy, cpplint, lizard complexity
- **Security Scanning**: gitleaks, trufflehog, semgrep SAST, trivy
- **Secrets Detection**: Multiple tools for credential leak detection
- **Linting**: Shell scripts, YAML, Markdown, C++ style compliance
- **Dependency Analysis**: License compliance, vulnerability scanning
- **Infrastructure Checks**: File permissions, configuration validation

**Artifacts Produced**:
- `static-analysis-results/` - Comprehensive code quality reports
- `security-scan-results/` - Security and secrets analysis
- `dependency-analysis-results/` - License and dependency reports
- `comprehensive-analysis-report/` - Executive summary and recommendations

### 3. `quick-ci.yml` - Fast Feedback Loop
**Triggers**: All pushes and PRs
**Purpose**: Quick validation for development workflow

**Features**:
- **Fast Execution**: Basic validation only (~2-3 minutes)
- **Dependency Caching**: Speeds up subsequent runs
- **Script Testing**: Validates build scripts work
- **Documentation Check**: Ensures docs are present

### 4. `dependency-check.yml` - Dependency Monitoring
**Triggers**: Weekly schedule (Mondays), Manual dispatch
**Purpose**: Monitor dependency compatibility and updates

**Features**:
- **Weekly Automated Check**: Runs every Monday
- **Multi-Version Testing**: Tests Ubuntu 20.04, 22.04, 24.04
- **Dependency Reports**: Generates version reports
- **Failure Notifications**: Auto-creates issues when dependencies break

## Enhanced Static Analysis and Security

The `enhanced-static-analysis.yml` workflow provides comprehensive code quality and security analysis:

### Code Quality Tools:
- **cppcheck**: Static analysis for C++ code with extensive rule sets
- **clang-tidy**: Modern C++ linting with modernization suggestions
- **cpplint**: Google C++ Style Guide compliance checking
- **lizard**: Cyclomatic complexity analysis and maintainability metrics
- **clang-format**: Code formatting consistency verification

### Security Analysis Tools:
- **gitleaks**: Scans Git history for secrets and credentials
- **trufflehog**: Advanced secret detection with entropy analysis
- **semgrep**: Static Application Security Testing (SAST) with security rules
- **trivy**: Vulnerability scanning for dependencies and configurations
- **Custom patterns**: Hardcoded credential and sensitive data detection

### Infrastructure Linting:
- **shellcheck**: Shell script quality and security analysis
- **yamllint**: YAML file structure and syntax validation
- **markdownlint**: Documentation formatting and consistency

### Dependency and License Analysis:
- **License compliance**: Source code license header verification
- **Vulnerability scanning**: Known security issues in dependencies
- **System package analysis**: Dependency version and security tracking

### Security Compliance:
- **File permission auditing**: SUID, world-writable file detection
- **Configuration scanning**: Infrastructure as Code security
- **SARIF integration**: Results uploaded to GitHub Security tab

## Automation Benefits

### For Developers:
1. **Immediate Feedback**: Know if your changes break the build
2. **Multi-Platform Confidence**: Automatic testing on different systems
3. **Code Quality Guidance**: Automated suggestions for improvement
4. **Security Awareness**: Early detection of security issues
5. **Compliance Checking**: License and style guide enforcement
6. **Documentation Sync**: Ensures documentation stays current

### For Maintainers:
1. **Release Automation**: Tagged commits automatically create GitHub releases
2. **Security Monitoring**: Continuous vulnerability and secret scanning
3. **Dependency Tracking**: Weekly reports on system dependency changes
4. **Quality Assurance**: Consistent build environment and testing
5. **Compliance Oversight**: License and security policy enforcement

### For Users:
1. **Pre-built Packages**: Download ready-to-use binaries
2. **Build Confidence**: Know that the build process is tested
3. **Security Assurance**: Regular security scanning and monitoring
4. **Platform Support**: Clear compatibility information
5. **Easy Installation**: Validated dependency installation scripts

## Workflow Configuration

### Environment Variables
```yaml
BUILD_TYPE: Release          # Default build configuration
MOOS_IVP_ROOT: $GITHUB_WORKSPACE  # Set automatically
```

### Secrets Required
- `GITHUB_TOKEN` - Automatically provided for releases and issue creation

### Customization Options

#### Build Matrix
Modify the matrix in `build-and-test.yml` to add/remove platforms:
```yaml
strategy:
  matrix:
    ubuntu-version: [20.04, 22.04, 24.04]  # Add/remove versions
    build-type: [Release, Debug]           # Add MinSizeRel, RelWithDebInfo
```

#### Dependency Schedule
Change the dependency check frequency in `dependency-check.yml`:
```yaml
schedule:
  - cron: '0 6 * * 1'  # Weekly on Monday
  # - cron: '0 6 1 * *'  # Monthly on 1st
  # - cron: '0 6 * * *'  # Daily
```

## Setting Up Workflows

### 1. Enable GitHub Actions
1. Go to repository Settings → Actions → General
2. Set "Actions permissions" to "Allow all actions and reusable workflows"
3. Enable "Allow GitHub Actions to create and approve pull requests"

### 2. Configure Branch Protection
For best practices, protect the main branch:
1. Settings → Branches → Add rule for `main`
2. Check "Require status checks to pass before merging"
3. Select the CI workflows as required checks

### 3. Set Up Notifications
Configure notifications for workflow failures:
1. Settings → Notifications
2. Enable "Actions" notifications
3. Consider setting up Slack/email integrations

## Monitoring and Maintenance

### Regular Tasks:
- **Weekly**: Review dependency check reports
- **Monthly**: Update workflow runner versions
- **Quarterly**: Review and update dependencies in `install-dependencies.sh`

### Key Metrics to Monitor:
- Build success rate (target: >95%)
- Average build time (target: <15 minutes for full build)
- Dependency check failures
- Security scan alerts

### Troubleshooting Common Issues:

#### Build Failures:
1. Check if dependencies changed (review dependency-check reports)
2. Verify `install-dependencies.sh` works on target platform
3. Look for new compiler warnings/errors
4. Check if submodules need updates

#### Dependency Issues:
1. Review weekly dependency reports
2. Check Ubuntu package repository changes
3. Update package names in `install-dependencies.sh`
4. Consider pinning problematic package versions

#### Performance Issues:
1. Review build cache effectiveness
2. Consider reducing matrix size for feature branches
3. Optimize dependency installation caching
4. Move expensive operations to scheduled workflows

## Future Enhancements

### Planned Improvements:
- **Docker Support**: Build and test in containers
- **Cross-Compilation**: ARM64, Windows support
- **Performance Testing**: Automated benchmarks
- **Integration Tests**: Full mission simulation tests
- **Documentation Generation**: Automated API docs
- **Package Distribution**: APT/YUM repository publishing

### Advanced Features:
- **Conditional Workflows**: Skip builds when only docs change
- **Parallel Testing**: Matrix expansion for more comprehensive testing
- **Deployment Automation**: Automatic deployment to staging environments
- **Notification Integrations**: Slack, Discord, email notifications
- **Metrics Collection**: Build time, test coverage, performance metrics

## Contributing to Workflows

When modifying workflows:
1. Test changes on a fork first
2. Use `workflow_dispatch` for manual testing
3. Monitor resource usage and build times
4. Update documentation when adding new features
5. Consider backward compatibility

For questions about the CI/CD setup, check the workflow run logs or create an issue with the `ci-cd` label.
