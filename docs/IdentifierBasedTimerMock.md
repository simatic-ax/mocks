# IdentifierBasedTimerMock

## Overview

The `IdentifierBasedTimerMock` family provides flexible solutions for testing function blocks with **conditional timer usage**. Unlike duration-based matching, these mocks identify timers by their **call position** within the execution cycle, making them independent of timer duration values.

## Available Mocks

### System.Timer Interface (signal/duration)

- **`IdentifierBasedTimerMock`** - For `OnDelay` timers
- **`IdentifierBasedOffDelayMock`** - For `OffDelay` timers

### IEC 61131-3 Interface (IN/PT)

- **`IdentifierBasedTONMock`** - For `TON` (On-Delay) timers
- **`IdentifierBasedTOFMock`** - For `TOF` (Off-Delay) timers

## Key Concept

Each timer is configured with its **expected call position** (1st, 2nd, 3rd, or 4th call). This allows you to test scenarios where different timers are called at the same position depending on runtime conditions.

## Perfect For Conditional Timer Logic

```iec-st
// Timer 1 always called at position 1
timer1(signal := enable, duration := T#1s);

IF mode = 1 THEN
    // Timer 2 called at position 2 in mode 1
    timer2(signal := enable, duration := T#2s);
ELSIF mode = 2 THEN
    // Timer 3 called at position 2 in mode 2
    timer3(signal := enable, duration := T#3s);
END_IF;
```

In this example:

- **Position 1** is always `timer1`
- **Position 2** is `timer2` in mode 1, or `timer3` in mode 2

## Usage

### Basic Configuration

```iec-st
VAR
    payload : IdentifierBasedTimerMockPayload;  // Or IdentifierBasedOffDelayMockPayload, etc.
END_VAR

// Reset counter before each test
payload.ResetCounter();

// Configure Timer 1 at position 1
payload.T1_Enabled := TRUE;
payload.T1_CallPosition := 1;  // 1st call
payload.T1_Output := TRUE;
payload.T1_ElapsedTime := T#1s;

// Configure Timer 2 at position 2
payload.T2_Enabled := TRUE;
payload.T2_CallPosition := 2;  // 2nd call
payload.T2_Output := FALSE;
payload.T2_ElapsedTime := T#500ms;

// Apply mock for OnDelay
AxUnit.Mocking.Mock(
    mockeeFn := NAME_OF(OnDelay),
    mockFn := NAME_OF(IdentifierBasedTimerMock),
    payload := payload
);

// Or for OffDelay
AxUnit.Mocking.Mock(
    mockeeFn := NAME_OF(OffDelay),
    mockFn := NAME_OF(IdentifierBasedOffDelayMock),
    payload := IdentifierBasedOffDelayMockPayload
);

// Or for TON (IEC)
AxUnit.Mocking.Mock(
    mockeeFn := NAME_OF(TON_Mock_true),
    mockFn := NAME_OF(IdentifierBasedTONMock),
    payload := IdentifierBasedTONMockPayload
);

// Or for TOF (IEC)
AxUnit.Mocking.Mock(
    mockeeFn := NAME_OF(TOF_Mock_true),
    mockFn := NAME_OF(IdentifierBasedTOFMock),
    payload := IdentifierBasedTOFMockPayload
);
```

### Testing Conditional Timers

#### Mode 1: T1 + T2

```iec-st
payload.ResetCounter();

// Position 1: Timer 1 (always)
payload.T1_Enabled := TRUE;
payload.T1_CallPosition := 1;
payload.T1_Output := TRUE;
payload.T1_ElapsedTime := T#1s;

// Position 2: Timer 2 (mode 1)
payload.T2_Enabled := TRUE;
payload.T2_CallPosition := 2;
payload.T2_Output := TRUE;
payload.T2_ElapsedTime := T#2s;

// Test mode 1
testInstance(mode := 1, enable := TRUE);
```

#### Mode 2: T1 + T3

```iec-st
payload.ResetCounter();

// Position 1: Timer 1 (always)
payload.T1_Enabled := TRUE;
payload.T1_CallPosition := 1;
payload.T1_Output := TRUE;
payload.T1_ElapsedTime := T#1s;

// Position 2: Timer 3 (mode 2)
payload.T3_Enabled := TRUE;
payload.T3_CallPosition := 2;  // Same position as T2, but different mode
payload.T3_Output := FALSE;
payload.T3_ElapsedTime := T#1500ms;

// Test mode 2
testInstance(mode := 2, enable := TRUE);
```

## Payload Configuration

Each mock has its own payload class:
- `IdentifierBasedTimerMockPayload` - For OnDelay
- `IdentifierBasedOffDelayMockPayload` - For OffDelay
- `IdentifierBasedTONMockPayload` - For TON
- `IdentifierBasedTOFMockPayload` - For TOF

All payload classes provide the following properties:

| Property | Type | Description |
|----------|------|-------------|
| `CallCounter` | INT | Internal counter tracking current call number |
| `LastCallDuration` or `LastCallPT` | LTIME | Debug: Last called duration/preset time |
| `LastCallSignal` or `LastCallIN` | BOOL | Debug: Last called signal/input |
| `TX_Enabled` | BOOL | Enable this timer configuration |
| `TX_CallPosition` | INT | Expected call position (1-4) |
| `TX_Output` | BOOL | Desired output state |
| `TX_ElapsedTime` | LTIME | Elapsed time to return |
| `ResetCounter()` | METHOD | Reset call counter before each test |

## How It Works

1. **Before test:** Call `payload.ResetCounter()` to reset counter to 0
2. Mock receives a timer call
3. Increments internal `CallCounter` (1, 2, 3, 4...)
4. Searches for a timer configuration where:
   - `TX_Enabled = TRUE`
   - `TX_CallPosition = CallCounter`
5. Returns configured output and elapsed time for matched timer
6. If no match, returns FALSE and 0ms

## Advantages

✅ **Duration-independent** - No dependency on timer duration values  
✅ **Perfect for conditional logic** - Different timers at same position  
✅ **Flexible** - Configure any timer at any position  
✅ **Clear intent** - Call position makes test logic explicit  
✅ **Debug support** - LastCallDuration and LastCallSignal for troubleshooting

## Important Notes

### Always Reset Counter

**Must call `payload.ResetCounter()` before each test!**

```iec-st
{Test}
METHOD PUBLIC MyTest
    payload.ResetCounter();  // ← Essential!
    // ... configure and test ...
END_METHOD
```

### Understanding Call Positions

Call position is determined by the **order of execution**, not by variable declaration:

```iec-st
VAR
    timer1 : OnDelay;  // Declared first
    timer2 : OnDelay;  // Declared second
END_VAR

timer2(signal := ...);  // ← Position 1 (called first!)
timer1(signal := ...);  // ← Position 2 (called second!)
```

### Conditional vs Sequential

**Conditional (different timers at same position):**

```iec-st
IF mode = 1 THEN
    timer2(...);  // Position 2
ELSE
    timer3(...);  // Also position 2
END_IF;
```

**Sequential (all timers always called):**

```iec-st
timer1(...);  // Position 1
timer2(...);  // Position 2
timer3(...);  // Position 3
```

## Comparison with Other Mocks

| Mock | Identification Method | Best For |
|------|----------------------|----------|
| `OnDelayMock_true/false` | N/A (single state) | Single timer or all same state |
| `ConfigurableTimerMock` | Call order (sequential) | Multiple timers with different states |
| `IdentifierBasedTimerMock` | Call position | **Conditional timer logic** ✅ |

## Real-World Example

```iec-st
FUNCTION_BLOCK HeatingController
    VAR_INPUT
        mode : INT;  // 1=Fast, 2=Slow, 3=Eco
    END_VAR
    VAR
        preHeat : OnDelay;
        fastHeat : OnDelay;
        slowHeat : OnDelay;
        ecoHeat : OnDelay;
    END_VAR
    
    // Always pre-heat (position 1)
    preHeat(signal := TRUE, duration := T#5s);
    
    IF preHeat.output THEN
        IF mode = 1 THEN
            fastHeat(signal := TRUE, duration := T#10s);  // Position 2
        ELSIF mode = 2 THEN
            slowHeat(signal := TRUE, duration := T#30s);  // Position 2
        ELSIF mode = 3 THEN
            ecoHeat(signal := TRUE, duration := T#60s);   // Position 2
        END_IF;
    END_IF;
END_FUNCTION_BLOCK
```

**Test all modes with position-based configuration:**

```iec-st
// Position 1: preHeat (always)
payload.T1_CallPosition := 1;
payload.T1_Output := TRUE;

// Position 2: fastHeat (mode 1)
payload.T2_CallPosition := 2;
payload.T2_Output := TRUE;

// Position 2: slowHeat (mode 2)
payload.T3_CallPosition := 2;
payload.T3_Output := FALSE;

// Position 2: ecoHeat (mode 3)
payload.T4_CallPosition := 2;
payload.T4_Output := TRUE;
```

## See Also

- **Test Examples:**
  - [`IdentifierBasedTimerMockTest.st`](../test/IdentifierBasedTimerMockTest.st) - OnDelay examples
  - [`IdentifierBasedOffDelayMockTest.st`](../test/IdentifierBasedOffDelayMockTest.st) - OffDelay examples
  - [`IdentifierBasedTONMockTest.st`](../test/IdentifierBasedTONMockTest.st) - TON examples
  - [`IdentifierBasedTOFMockTest.st`](../test/IdentifierBasedTOFMockTest.st) - TOF examples
- **Other Mocks:**
  - [`ConfigurableTimerMock`](ConfigurableTimerMock.md) - Sequential timer mocks
  - [`SimpleMocks_RealWorld_Test.st`](../test/SimpleMocks_RealWorld_Test.st) - Simple mock examples
- **Overview:**
  - [`TimerMocks-Overview.md`](TimerMocks-Overview.md) - Complete overview and decision guide
