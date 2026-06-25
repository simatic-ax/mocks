# Timer Mocks - Complete Overview

## Introduction

This document provides a comprehensive overview of all timer mocks available in the `@simatic-ax/mocks` package. It helps you choose the right mock for your testing scenario and understand the differences between various mock types.

## Mock Categories

### 1. Simple Timer Mocks

⚠️ **IMPORTANT LIMITATION:** Simple mocks set **ALL** timers in your function block to the **same state**.

**Use simple mocks ONLY when:**

- ✅ You have a **single timer** in your function block
- ✅ **All timers** should have the **same state** (all elapsed OR all waiting)

**Do NOT use simple mocks when:**

- ❌ You need **different states** for different timers (e.g., timer1=TRUE, timer2=FALSE)
- ❌ You have **conditional timer logic** (IF/CASE statements)

For these scenarios, use [`ConfigurableOnDelayMock`](#ConfigurableOnDelayMock) or [`IdentifierBasedOnDelayMock`](#IdentifierBasedOnDelayMock).

#### System.Timer Interface (signal/duration)

| Mock | Output | ElapsedTime | File |
|------|--------|-------------|------|
| `OnDelayMock_false` | FALSE | 0ms | [OnDelayMock_false.st](../src/System/Timer/OnDelayMock_false.st) |
| `OnDelayMock_true` | TRUE | duration | [OnDelayMock_true.st](../src/System/Timer/OnDelayMock_true.st) |
| `OffDelayMock_false` | FALSE | 0ms | [OffDelayMock_false.st](../src/System/Timer/OffDelayMock_false.st) |
| `OffDelayMock_true` | TRUE | duration | [OffDelayMock_true.st](../src/System/Timer/OffDelayMock_true.st) |

**Interface:**

```iecst
VAR_INPUT
    signal : BOOL;
    duration : LTIME;
END_VAR
VAR_OUTPUT
    output : BOOL;
    elapsedTime : LTIME;
END_VAR
```

#### IEC 61131-3 Standard Interface (IN/PT)

| Mock | Q Output | ET | File |
|------|----------|-----|------|
| `TON_Mock_false` | FALSE | 0ms | [TON_Mock_false.st](../src/IEC/Timer/TON_Mock_false.st) |
| `TON_Mock_true` | TRUE | PT | [TON_Mock_true.st](../src/IEC/Timer/TON_Mock_true.st) |
| `TOF_Mock_false` | FALSE | 0ms | [TOF_Mock_false.st](../src/IEC/Timer/TOF_Mock_false.st) |
| `TOF_Mock_true` | TRUE | PT | [TOF_Mock_true.st](../src/IEC/Timer/TOF_Mock_true.st) |

**Interface:**

```iecst
VAR_INPUT
    IN : BOOL;
    PT : LTIME;
END_VAR
VAR_OUTPUT
    Q : BOOL;
    ET : LTIME;
END_VAR
```

**Example Usage:**

✅ **CORRECT - Single Timer:**

```iecst
FUNCTION_BLOCK SingleTimerController
    VAR timer : OnDelay; END_VAR
    timer(signal := enable, duration := T#5s);
END_FUNCTION_BLOCK

{Test}
METHOD PUBLIC Test_TimerElapsed
    AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
    // ✅ Works perfectly - only one timer
END_METHOD
```

✅ **CORRECT - All Timers Same State:**

```iecst
FUNCTION_BLOCK AllTimersSameState
    VAR timer1, timer2, timer3 : OnDelay; END_VAR
    // All must be elapsed
    IF timer1.output AND timer2.output AND timer3.output THEN
        allReady := TRUE;
    END_IF;
END_FUNCTION_BLOCK

{Test}
METHOD PUBLIC Test_AllElapsed
    AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
    // ✅ Works - all timers need same state (all TRUE)
END_METHOD
```

❌ **WRONG - Mixed Timer States:**

```iecst
FUNCTION_BLOCK MixedTimerStates
    VAR timer1, timer2, timer3 : OnDelay; END_VAR
    // Need: timer1=TRUE, timer2=FALSE, timer3=TRUE
END_FUNCTION_BLOCK

{Test}
METHOD PUBLIC Test_MixedStates
    AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
    // ❌ WRONG! All timers will be TRUE, cannot have mixed states
    // ✅ SOLUTION: Use ConfigurableOnDelayMock instead!
END_METHOD
```

📖 See [SimpleMocks_RealWorld_Test.st](../test/SimpleMocks_RealWorld_Test.st) for complete examples.

### 2. Configurable Timer Mocks

Advanced mocks that support multiple timer instances with **individual states**.

#### ConfigurableOnDelayMock Family

**Identification:** Call-order based (1st call = T1, 2nd call = T2, etc.)

**Best for:**

- Sequential timers always called in the same order
- Multiple timers with **different states**
- Multiple timers with identical durations
- Simple multi-timer scenarios

**Features:**

- ✅ Supports up to 4 timer instances
- ✅ **Each timer can have individual state** (unlike simple mocks)
- ✅ Works with identical durations
- ✅ Simple configuration
- ✅ Automatic call counting
- ⚠️ Requires consistent call order
- ⚠️ Not suitable for conditional timer logic

**Available Mocks:**

| Timer Type | Mock | Payload | File |
|------------|------|---------|------|
| System.Timer.OnDelay | `ConfigurableOnDelayMock` | `ConfigurableOnDelayMockPayload` | [ConfigurableOnDelayMock.st](../src/System/Timer/ConfigurableOnDelayMock.st) |
| System.Timer.OffDelay | `ConfigurableOffDelayMock` | `ConfigurableOffDelayMockPayload` | [ConfigurableOffDelayMock.st](../src/System/Timer/ConfigurableOffDelayMock.st) |
| IEC TON | `ConfigurableTONMock` | `ConfigurableTONMockPayload` | [ConfigurableTONMock.st](../src/IEC/Timer/ConfigurableTONMock.st) |
| IEC TOF | `ConfigurableTOFMock` | `ConfigurableTOFMockPayload` | [ConfigurableTOFMock.st](../src/IEC/Timer/ConfigurableTOFMock.st) |

**Documentation & Tests:**

- Documentation: [ConfigurableOnDelayMock.md](ConfigurableOnDelayMock.md)
- Tests:
  - [ConfigurableOnDelayMockTest.st](../test/System/Timer/ConfigurableOnDelayMockTest.st) - OnDelay
  - [ConfigurableOffDelayMockTest.st](../test/System/Timer/ConfigurableOffDelayMockTest.st) - OffDelay
  - [ConfigurableTONMockTest.st](../test/IEC/Timer/ConfigurableTONMockTest.st) - TON
  - [ConfigurableTOFMockTest.st](../test/IEC/Timer/ConfigurableTOFMockTest.st) - TOF

**Example:**

```iecst
payload.ResetCounter();
payload.T1_Enabled := TRUE;
payload.T1_Output := TRUE;      // Timer 1: elapsed
payload.T1_ElapsedTime := T#1s;

payload.T2_Enabled := TRUE;
payload.T2_Output := FALSE;     // Timer 2: waiting (different state!)
payload.T2_ElapsedTime := T#500ms;
```

#### IdentifierBasedOnDelayMock Family

**Identification:** Position-based with explicit call positions

**Best for:**

- Conditional timer logic (IF/CASE statements)
- Different timers at the same position
- Complex branching scenarios
- Multiple timers with **different states**

**Features:**

- ✅ Supports up to 4 timer instances
- ✅ **Each timer can have individual state** (unlike simple mocks)
- ✅ Perfect for conditional logic
- ✅ Duration-independent
- ✅ Explicit position configuration
- ✅ Different timers can share positions
- ⚠️ Requires understanding of call positions

**Available Mocks:**

| Timer Type | Mock | Payload | File |
|------------|------|---------|------|
| System.Timer.OnDelay | `IdentifierBasedOnDelayMock` | `IdentifierBasedOnDelayMockPayload` | [IdentifierBasedOnDelayMock.st](../src/System/Timer/IdentifierBasedOnDelayMock.st) |
| System.Timer.OffDelay | `IdentifierBasedOffDelayMock` | `IdentifierBasedOffDelayMockPayload` | [IdentifierBasedOffDelayMock.st](../src/System/Timer/IdentifierBasedOffDelayMock.st) |
| IEC TON | `IdentifierBasedTONMock` | `IdentifierBasedTONMockPayload` | [IdentifierBasedTONMock.st](../src/IEC/Timer/IdentifierBasedTONMock.st) |
| IEC TOF | `IdentifierBasedTOFMock` | `IdentifierBasedTOFMockPayload` | [IdentifierBasedTOFMock.st](../src/IEC/Timer/IdentifierBasedTOFMock.st) |

**Documentation & Tests:**

- Documentation: [IdentifierBasedOnDelayMock.md](IdentifierBasedOnDelayMock.md)
- Tests:
  - [IdentifierBasedOnDelayMockTest.st](../test/System/Timer/IdentifierBasedOnDelayMockTest.st) - OnDelay
  - [IdentifierBasedOffDelayMockTest.st](../test/System/Timer/IdentifierBasedOffDelayMockTest.st) - OffDelay
  - [IdentifierBasedTONMockTest.st](../test/IEC/Timer/IdentifierBasedTONMockTest.st) - TON
  - [IdentifierBasedTOFMockTest.st](../test/IEC/Timer/IdentifierBasedTOFMockTest.st) - TOF

**Example:**

```iecst
payload.ResetCounter();
payload.T1_Enabled := TRUE;
payload.T1_CallPosition := 1;  // Always at position 1
payload.T1_Output := TRUE;

payload.T2_Enabled := TRUE;
payload.T2_CallPosition := 2;  // At position 2 in mode 1
payload.T2_Output := FALSE;

payload.T3_Enabled := TRUE;
payload.T3_CallPosition := 2;  // At position 2 in mode 2 (same position!)
payload.T3_Output := TRUE;
```

## Decision Guide

### Flowchart: Choosing the Right Mock

```
Start
  │
  ├─ Single timer with fixed state?
  │   └─ YES → Use OnDelayMock_true/false or TON_Mock_true/false ✅
  │
  ├─ Multiple timers, ALL same state?
  │   └─ YES → Use OnDelayMock_true/false or TON_Mock_true/false ✅
  │
  ├─ Multiple timers with DIFFERENT states?
  │   │
  │   ├─ All timers always called in same order?
  │   │   └─ YES → Use ConfigurableOnDelayMock ✅
  │   │
  │   ├─ Conditional timer logic (IF/CASE)?
  │   │   └─ YES → Use IdentifierBasedOnDelayMock ✅
```

### Comparison Table

| Feature | Simple Mocks | ConfigurableOnDelayMock | IdentifierBasedOnDelayMock |
|---------|--------------|----------------------|--------------------------|
| **Max Timers** | Unlimited (all same state) | 4 | 4 |
| **Individual States** | ❌ All same | ✅ Each different | ✅ Each different |
| **Identification** | N/A | Call order | Position |
| **Conditional Logic** | ❌ | ❌ | ✅ |
| **Same Duration** | ✅ | ✅ | ✅ |
| **Configuration Complexity** | Simple | Medium | Medium |
| **Payload Required** | ❌ | ✅ | ✅ |
| **Reset Counter** | ❌ | ✅ | ✅ |

## Usage Patterns

### Pattern 1: Simple Single Timer

**Scenario:** Testing a function block with one timer

```iecst
{Test}
METHOD PUBLIC TestTimerElapsed
    // ✅ CORRECT: Single timer
    AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
    myFB(enable := TRUE);
    Equal(expected := TRUE, actual := myFB.output);
END_METHOD
```

### Pattern 2: Multiple Timers - All Same State

**Scenario:** All timers must be elapsed

```iecst
{Test}
METHOD PUBLIC TestAllTimersElapsed
    // ✅ CORRECT: All timers need same state
    AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
    myFB(enable := TRUE);
    Equal(expected := TRUE, actual := myFB.allReady);
END_METHOD
```

### Pattern 3: Multiple Sequential Timers - Different States

**Scenario:** Function block with 3 timers always called in order, need different states

```iecst
{Test}
METHOD PUBLIC TestMultipleTimersDifferentStates
    payload.ResetCounter();
    payload.T1_Enabled := TRUE;
    payload.T1_Output := TRUE;      // Timer 1: elapsed
    payload.T2_Enabled := TRUE;
    payload.T2_Output := FALSE;     // Timer 2: waiting
    payload.T3_Enabled := TRUE;
    payload.T3_Output := TRUE;      // Timer 3: elapsed
    
    AxUnit.Mocking.Mock(
        mockeeFn := NAME_OF(OnDelay),
        mockFn := NAME_OF(ConfigurableOnDelayMock),
        payload := payload
    );
    
    myFB();
END_METHOD
```

### Pattern 4: Conditional Timer Logic

**Scenario:** Different timers called based on mode

```iecst
FUNCTION_BLOCK MyFB
    timer1(signal := enable, duration := T#1s);  // Always
    IF mode = 1 THEN
        timer2(signal := enable, duration := T#2s);  // Mode 1
    ELSE
        timer3(signal := enable, duration := T#3s);  // Mode 2
    END_IF;
END_FUNCTION_BLOCK

{Test}
METHOD PUBLIC TestMode1
    payload.ResetCounter();
    payload.T1_CallPosition := 1;  // timer1
    payload.T1_Output := TRUE;
    payload.T2_CallPosition := 2;  // timer2 in mode 1
    payload.T2_Output := TRUE;
    
    AxUnit.Mocking.Mock(
        mockeeFn := NAME_OF(OnDelay),
        mockFn := NAME_OF(IdentifierBasedOnDelayMock),
        payload := payload
    );
    
    myFB(mode := 1);
END_METHOD
```

## Best Practices

### 1. Always Use Stateless Pattern

```iecst
{TestFixture}
CLASS MyTests
    VAR
        myFB, myFBStateless : MyFunctionBlock;
        payload, payloadStateless : ConfigurableOnDelayMockPayload;
    END_VAR

    {TestSetup}
    METHOD PUBLIC TestSetup
        payload := payloadStateless;
        myFB := myFBStateless;
    END_METHOD
END_CLASS
```

### 2. Reset Counter Before Each Test

```iecst
{Test}
METHOD PUBLIC MyTest
    payload.ResetCounter();  // Essential for call-order mocks!
    // ... test code ...
END_METHOD
```

### 3. Document Call Order

```iecst
// Timer call order in MyFB:
// 1. preHeatTimer (always)
// 2. mainTimer (mode 1) OR backupTimer (mode 2)
// 3. cooldownTimer (always)

payload.T1_CallPosition := 1;  // preHeatTimer
payload.T2_CallPosition := 2;  // mainTimer (mode 1)
payload.T3_CallPosition := 3;  // cooldownTimer
```

### 4. Use Descriptive Test Names

```iecst
{Test}
METHOD PUBLIC Test_Mode1_PreHeatElapsed_MainWaiting_CooldownNotStarted
    // Clear test intent from method name
END_METHOD
```

## Common Pitfalls

### ❌ Using Simple Mocks for Mixed States

```iecst
// Code needs: timer1=TRUE, timer2=FALSE, timer3=TRUE
{Test}
METHOD PUBLIC Test_MixedStates
    // ❌ WRONG: Simple mock sets ALL timers to same state
    AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
    // All timers will be TRUE!
END_METHOD
```

**✅ Solution:** Use `ConfigurableOnDelayMock` or `IdentifierBasedOnDelayMock`.

### ❌ Forgetting to Reset Counter

```iecst
{Test}
METHOD PUBLIC Test1
    // Missing: payload.ResetCounter();
    payload.T1_Output := TRUE;
    // Counter continues from previous test!
END_METHOD
```

**✅ Solution:** Always call `ResetCounter()` at the start of each test.

### ❌ Wrong Call Position

```iecst
// Code calls: timer1, timer2, timer3
// Test configures:
payload.T1_CallPosition := 1;  // ✅ Correct
payload.T2_CallPosition := 3;  // ❌ Wrong! Should be 2
payload.T3_CallPosition := 2;  // ❌ Wrong! Should be 3
```

**✅ Solution:** Match call positions to actual execution order.

### ❌ Using Call-Order for Conditional Logic

```iecst
// Code has conditional timers
IF mode = 1 THEN timer2(); ELSE timer3(); END_IF;

// Using ConfigurableOnDelayMock (call-order)
payload.T2_Enabled := TRUE;  // ❌ Won't work reliably!
```

**✅ Solution:** Use `IdentifierBasedOnDelayMock` for conditional logic.

## Test Examples

All mocks include comprehensive test coverage:

- [SimpleMocks_RealWorld_Test.st](../test/SimpleMocks_RealWorld_Test.st) - **Real-world examples for simple mocks**
- [IEC_TON_Mocks_Test.st](../test/IEC/Timer/IEC_TON_Mocks_Test.st) - IEC TON timer tests
- [IEC_TOF_Mocks_Test.st](../test/IEC/Timer/IEC_TOF_Mocks_Test.st) - IEC TOF timer tests
- [System_OnDelay_Mocks_Test.st](../test/System/Timer/System_OnDelay_Mocks_Test.st) - System OnDelay tests
- [System_OffDelay_Mocks_Test.st](../test/System/Timer/System_OffDelay_Mocks_Test.st) - System OffDelay tests
- [ConfigurableOnDelayMockTest.st](../test/System/Timer/ConfigurableOnDelayMockTest.st) - Configurable mock tests
- [IdentifierBasedOnDelayMockTest.st](../test/System/Timer/IdentifierBasedOnDelayMockTest.st) - Identifier-based tests
- [FooFB_ConfigurableMock_Test.st](../test/FooFB_ConfigurableMock_Test.st) - Real-world example
- [FooFB_IdentifierMock_Test.st](../test/FooFB_IdentifierMock_Test.st) - Real-world example
- [ConfigurableOffDelayMockTest.st](../test/System/Timer/ConfigurableOffDelayMockTest.st) - OffDelay configurable mock
- [IdentifierBasedOffDelayMockTest.st](../test/System/Timer/IdentifierBasedOffDelayMockTest.st) - OffDelay identifier-based
- [ConfigurableTONMockTest.st](../test/IEC/Timer/ConfigurableTONMockTest.st) - TON configurable mock
- [IdentifierBasedTONMockTest.st](../test/IEC/Timer/IdentifierBasedTONMockTest.st) - TON identifier-based
- [ConfigurableTOFMockTest.st](../test/IEC/Timer/ConfigurableTOFMockTest.st) - TOF configurable mock
- [IdentifierBasedTOFMockTest.st](../test/IEC/Timer/IdentifierBasedTOFMockTest.st) - TOF identifier-based

## Summary

This package provides a complete suite of timer mocks for every testing scenario:

1. **Simple Mocks** - Quick and easy for single timer or all same state ⚠️
   - OnDelay/OffDelay (System.Timer)
   - TON/TOF (IEC 61131-3)
2. **ConfigurableOnDelayMock Family** - Flexible for multiple sequential timers with different states
   - ConfigurableOnDelayMock (OnDelay)
   - ConfigurableOffDelayMock (OffDelay)
   - ConfigurableTONMock (TON)
   - ConfigurableTOFMock (TOF)
3. **IdentifierBasedOnDelayMock Family** - Perfect for conditional timer logic with different states
   - IdentifierBasedOnDelayMock (OnDelay)
   - IdentifierBasedOffDelayMock (OffDelay)
   - IdentifierBasedTONMock (TON)
   - IdentifierBasedTOFMock (TOF)

**Key Takeaway:** Simple mocks set ALL timers to the same state. For different states, use configurable or identifier-based mocks.

Choose the right mock based on your specific testing needs, and always follow best practices for reliable, maintainable tests.
