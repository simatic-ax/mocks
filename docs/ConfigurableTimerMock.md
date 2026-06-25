# ConfigurableTimerMock

## Overview

The `ConfigurableOnDelayMock` family provides flexible mocks for timer function blocks that allow you to configure up to 4 different timer instances with individual states. This is particularly useful when testing function blocks that use multiple timers.

## Available Mocks

### System.Timer Interface (signal/duration)

- **`ConfigurableOnDelayMock`** - For `OnDelay` timers
- **`ConfigurableOffDelayMock`** - For `OffDelay` timers

### IEC 61131-3 Interface (IN/PT)

- **`ConfigurableTONMock`** - For `TON` (On-Delay) timers
- **`ConfigurableTOFMock`** - For `TOF` (Off-Delay) timers

**Important:** Timers are identified by their **call order**, not by duration. This means the 1st timer call maps to T1, the 2nd call to T2, etc. This allows testing multiple timers even if they have the same duration.

## Features

- **Support for up to 4 timer instances** - Configure T1, T2, T3, and T4 independently
- **Call-order based identification** - Timers identified by call sequence (1st, 2nd, 3rd, 4th call)
- **Works with identical durations** - Multiple timers can have the same duration
- **Individual timer control** - Each timer can be enabled/disabled and configured separately
- **Full state control** - Set output state and elapsed time for each timer
- **Multiple timer types supported** - OnDelay, OffDelay, TON, TOF

## Usage

### Basic Example

```iec-st
VAR
    payload : ConfigurableOnDelayMockPayload;
END_VAR

// Reset counter before each test
payload.ResetCounter();

// Configure Timer 1 (1st call - elapsed)
payload.T1_Enabled := TRUE;
payload.T1_Output := TRUE;
payload.T1_ElapsedTime := T#1s;

// Configure Timer 2 (2nd call - still running)
payload.T2_Enabled := TRUE;
payload.T2_Output := FALSE;
payload.T2_ElapsedTime := T#500ms;

// Apply the mock for OnDelay
AxUnit.Mocking.Mock(
    mockeeFn := NAME_OF(OnDelay),
    mockFn := NAME_OF(ConfigurableOnDelayMock),
    payload := payload
);

// Or for OffDelay
AxUnit.Mocking.Mock(
    mockeeFn := NAME_OF(OffDelay),
    mockFn := NAME_OF(ConfigurableOffDelayMock),
    payload := ConfigurableOffDelayMockPayload
);

// Or for TON (IEC)
AxUnit.Mocking.Mock(
    mockeeFn := NAME_OF(TON_Mock_true),
    mockFn := NAME_OF(ConfigurableTONMock),
    payload := ConfigurableTONMockPayload
);

// Or for TOF (IEC)
AxUnit.Mocking.Mock(
    mockeeFn := NAME_OF(TOF_Mock_true),
    mockFn := NAME_OF(ConfigurableTOFMock),
    payload := ConfigurableTOFMockPayload
);
```

### Payload Configuration

Each mock has its own payload class:
- `ConfigurableOnDelayMockPayload` - For OnDelay
- `ConfigurableOffDelayMockPayload` - For OffDelay
- `ConfigurableTONMockPayload` - For TON
- `ConfigurableTOFMockPayload` - For TOF

All payload classes provide the following properties for each timer (T1-T4):

| Property | Type | Description |
|----------|------|-------------|
| `CallCounter` | INT | Internal counter tracking call order (auto-incremented) |
| `TX_Enabled` | BOOL | Enable/disable this timer configuration |
| `TX_Output` | BOOL | Desired output state for this timer |
| `TX_ElapsedTime` | LTIME | Elapsed time to return for this timer |
| `ResetCounter()` | METHOD | Reset call counter - **call before each test** |

### Example Scenarios

#### Scenario 1: Testing with T1 elapsed, T2 and T3 waiting

```iec-st
payload.ResetCounter();

payload.T1_Enabled := TRUE;
payload.T1_Output := TRUE;        // 1st timer call: elapsed
payload.T1_ElapsedTime := T#1s;

payload.T2_Enabled := TRUE;
payload.T2_Output := FALSE;       // 2nd timer call: still running
payload.T2_ElapsedTime := T#800ms;

payload.T3_Enabled := TRUE;
payload.T3_Output := FALSE;       // 3rd timer call: still running
payload.T3_ElapsedTime := T#2s;
```

#### Scenario 2: Testing with only specific timers enabled

```iec-st
payload.ResetCounter();

// Only configure Timer 2 (2nd call), others will default to FALSE
payload.T1_Enabled := FALSE;  // 1st call returns FALSE

payload.T2_Enabled := TRUE;   // 2nd call returns TRUE
payload.T2_Output := TRUE;
payload.T2_ElapsedTime := T#2s;

payload.T3_Enabled := FALSE;  // 3rd call returns FALSE
```

## How It Works

1. **Before test:** Call `payload.ResetCounter()` to reset the call counter to 0
2. The mock receives a timer call with `duration` and `signal` parameters
3. It retrieves the payload configuration using `AxUnit.Mocking.GetPayload()`
4. It increments the internal `CallCounter` (1st call → 1, 2nd call → 2, etc.)
5. It matches the timer by call order:
   - CallCounter = 1 → uses T1 configuration
   - CallCounter = 2 → uses T2 configuration
   - CallCounter = 3 → uses T3 configuration
   - CallCounter = 4 → uses T4 configuration
6. When a match is found and the timer is enabled, it returns the configured output and elapsed time
7. If not enabled or counter > 4, it returns FALSE and 0ms as defaults

## Complete Test Examples

See the following test files for complete examples:

- [`ConfigurableOnDelayMockTest.st`](../test/System/Timer/ConfigurableOnDelayMockTest.st) - OnDelay examples
- [`ConfigurableOffDelayMockTest.st`](../test/System/Timer/ConfigurableOffDelayMockTest.st) - OffDelay examples
- [`ConfigurableTONMockTest.st`](../test/IEC/Timer/ConfigurableTONMockTest.st) - TON examples
- [`ConfigurableTOFMockTest.st`](../test/IEC/Timer/ConfigurableTOFMockTest.st) - TOF examples

All demonstrate:
- Multiple timers with different states
- All timers in same state
- Selective timer configuration

## Important Notes

### Call Counter Reset

**Always call `payload.ResetCounter()` before each test!** The call counter persists between tests, so failing to reset it will cause timers to be misidentified.

```iec-st
{Test}
METHOD PUBLIC MyTest
    payload.ResetCounter();  // ← Essential!
    // ... configure payload ...
END_METHOD
```

### Timer Call Order

The mock identifies timers by their **call order** within your function block, not by duration or variable name. Make sure you understand the execution order:

```iec-st
FUNCTION_BLOCK MyFB
    VAR
        timer1 : OnDelay;  // Will be 1st call (T1)
        timer2 : OnDelay;  // Will be 2nd call (T2)
        timer3 : OnDelay;  // Will be 3rd call (T3)
    END_VAR
    
    timer1(signal := ..., duration := T#1s);  // ← 1st call = T1
    timer2(signal := ..., duration := T#2s);  // ← 2nd call = T2
    timer3(signal := ..., duration := T#5s);  // ← 3rd call = T3
END_FUNCTION_BLOCK
```

### Same Duration Support

Unlike duration-based mocking, this approach works even when multiple timers have the **same duration**:

```iec-st
timer1(signal := ..., duration := T#1s);  // ← 1st call = T1
timer2(signal := ..., duration := T#1s);  // ← 2nd call = T2 (same duration!)
timer3(signal := ..., duration := T#1s);  // ← 3rd call = T3 (same duration!)
```

## Advantages

- **Flexible testing** - Test complex timer scenarios without waiting for real time
- **Precise control** - Set exact states for each timer independently
- **Scalable** - Supports up to 4 timers in a single test
- **Works with identical durations** - No requirement for unique durations
- **Reusable** - One mock for multiple timer configurations
- **Clear intent** - Payload structure makes test setup explicit and readable

## See Also

- **Simple Mocks:**
  - [`OnDelayMock_true/false`](../src/System/Timer/) - System.Timer simple mocks
  - [`TON_Mock_true/false`](../src/IEC/Timer/) - IEC TON simple mocks
  - [`TOF_Mock_true/false`](../src/IEC/Timer/) - IEC TOF simple mocks
- **Position-based Mocks:**
  - [`IdentifierBasedOnDelayMock`](../src/System/Timer/IdentifierBasedOnDelayMock.st) - For OnDelay
  - [`IdentifierBasedOffDelayMock`](../src/System/Timer/IdentifierBasedOffDelayMock.st) - For OffDelay
  - [`IdentifierBasedTONMock`](../src/IEC/Timer/IdentifierBasedTONMock.st) - For TON
  - [`IdentifierBasedTOFMock`](../src/IEC/Timer/IdentifierBasedTOFMock.st) - For TOF
