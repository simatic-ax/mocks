# Changelog

## [Unreleased]

### Added

#### New IEC 61131-3 Standard Timer Mocks

- `TON_Mock_false` - IEC TON (On-Delay Timer) mock returning Q=FALSE
- `TON_Mock_true` - IEC TON (On-Delay Timer) mock returning Q=TRUE
- `TOF_Mock_false` - IEC TOF (Off-Delay Timer) mock returning Q=FALSE
- `TOF_Mock_true` - IEC TOF (Off-Delay Timer) mock returning Q=TRUE

#### Advanced Configurable Timer Mocks

- `ConfigurableTimerMock` - Call-order based mock supporting up to 4 timer instances
  - Identifies timers by call sequence (1st, 2nd, 3rd, 4th call)
  - Works with timers having identical durations
  - Simple payload-based configuration
  - Includes `ResetCounter()` method for test isolation
  - **Each timer can have individual state** (unlike simple mocks)

- `IdentifierBasedTimerMock` - Position-based mock for conditional timer logic
  - Supports up to 4 timer instances with explicit call positions
  - Perfect for conditional timer usage (IF/CASE statements)
  - Duration-independent identification
  - Allows different timers at the same position
  - **Each timer can have individual state** (unlike simple mocks)

#### Documentation

- Added comprehensive documentation for `ConfigurableTimerMock`
- Added comprehensive documentation for `IdentifierBasedTimerMock`
- Added complete overview documentation (`TimerMocks-Overview.md`)
- Updated README.md with complete mock overview and usage examples
- **Added important limitation notes for simple mocks** (only for single timer or all same state)

#### Tests

- Added comprehensive tests for IEC TON mocks (`IEC_TON_Mocks_Test.st`)
- Added comprehensive tests for IEC TOF mocks (`IEC_TOF_Mocks_Test.st`)
- Added comprehensive tests for System OnDelay mocks (`System_OnDelay_Mocks_Test.st`)
- Added comprehensive tests for System OffDelay mocks (`System_OffDelay_Mocks_Test.st`)
- Added tests for ConfigurableTimerMock (`ConfigurableTimerMockTest.st`)
- Added tests for IdentifierBasedTimerMock (`IdentifierBasedTimerMockTest.st`)
- Added real-world example tests for FbWithThreeTimers using ConfigurableTimerMock
- Added real-world example tests for FbWithThreeTimers using IdentifierBasedTimerMock
- **Added real-world tests demonstrating correct usage of simple mocks** (`SimpleMocks_RealWorld_Test.st`)
  - Shows when to use simple mocks (single timer or all same state)
  - Shows limitations (cannot test mixed states)
  - Includes examples with SingleTimerController and EmergencyStopController
- All tests use stateless pattern for proper test isolation

### Changed

#### Enhanced Existing Mocks

- Updated `OnDelayMock_false` with inline comments and proper initialization
- Updated `OnDelayMock_true` with inline comments and elapsed time initialization
- Updated `OffDelayMock_false` with inline comments and proper initialization
- Updated `OffDelayMock_true` with inline comments and elapsed time initialization

#### Project Structure

- Reorganized timer mocks into subdirectories:
  - `src/System/Timer/` - System.Timer interface mocks (signal/duration)
  - `src/IEC/Timer/` - IEC 61131-3 standard interface mocks (IN/PT)

### Fixed

- Improved code documentation and inline comments across all mocks
- Added proper elapsed time initialization in all mock variants

## 2022-06-22

### Added

- Version 0.1.2
