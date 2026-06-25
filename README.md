# Mocks

## Description

This package provides comprehensive predefined mocks for the AXUnit testing framework. It includes simple timer mocks as well as advanced configurable mocks for complex testing scenarios with multiple timers.

## Install this package

```cli
apax add @simatic-ax/mocks --dev
```

## Namespace

```iecst
Simatic.Ax.Mocks;
```

## Available Mocks

### Simple Timer Mocks

⚠️ **Important Limitation:** Simple mocks set **ALL** timers in your function block to the **same state**. Use them only when:

- You have a **single timer** in your function block, OR
- **All timers** should have the **same state** (all elapsed or all waiting)

For testing multiple timers with **different states**, use [`ConfigurableOnDelayMock`](#ConfigurableOnDelayMock) or [`IdentifierBasedOnDelayMock`](#IdentifierBasedOnDelayMock).

#### System.Timer Mocks (signal/duration interface)

| Name | Output | ElapsedTime | Use Case |
|------|--------|-------------|----------|
| [`OnDelayMock_false`](src/System/Timer/OnDelayMock_false.st) | FALSE | 0ms | Timer not elapsed |
| [`OnDelayMock_true`](src/System/Timer/OnDelayMock_true.st) | TRUE | duration | Timer elapsed |
| [`OffDelayMock_false`](src/System/Timer/OffDelayMock_false.st) | FALSE | 0ms | Timer not elapsed |
| [`OffDelayMock_true`](src/System/Timer/OffDelayMock_true.st) | TRUE | duration | Timer elapsed |

#### IEC 61131-3 Standard Mocks (IN/PT interface)

| Name | Q Output | ET | Use Case |
|------|----------|-----|----------|
| [`TON_Mock_false`](src/IEC/Timer/TON_Mock_false.st) | FALSE | 0ms | On-Delay not elapsed |
| [`TON_Mock_true`](src/IEC/Timer/TON_Mock_true.st) | TRUE | PT | On-Delay elapsed |
| [`TOF_Mock_false`](src/IEC/Timer/TOF_Mock_false.st) | FALSE | 0ms | Off-Delay not elapsed |
| [`TOF_Mock_true`](src/IEC/Timer/TOF_Mock_true.st) | TRUE | PT | Off-Delay elapsed |

**Example - Single Timer (✅ Correct Usage):**

```iecst
FUNCTION_BLOCK SingleTimerController
    VAR
        startupTimer : OnDelay;
    END_VAR
    startupTimer(signal := enable, duration := T#5s);
END_FUNCTION_BLOCK

{Test}
METHOD PUBLIC Test_StartupComplete
    // ✅ CORRECT: Only one timer - simple mock works perfectly
    AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
    controller(enable := TRUE);
    Equal(expected := TRUE, actual := controller.isReady);
END_METHOD
```

**Example - All Timers Same State (✅ Correct Usage):**

```iecst
FUNCTION_BLOCK MultiTimerAllSame
    VAR
        timer1, timer2, timer3 : OnDelay;
    END_VAR
    // All timers must be elapsed
    IF timer1.output AND timer2.output AND timer3.output THEN
        allReady := TRUE;
    END_IF;
END_FUNCTION_BLOCK

{Test}
METHOD PUBLIC Test_AllTimersElapsed
    // ✅ CORRECT: All timers need same state (all TRUE)
    AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
    controller(enable := TRUE);
    Equal(expected := TRUE, actual := controller.allReady);
END_METHOD
```

**Example - Mixed Timer States (❌ Wrong Usage):**

```iecst
FUNCTION_BLOCK MixedTimerStates
    VAR
        timer1, timer2, timer3 : OnDelay;
    END_VAR
    // Need: timer1=TRUE, timer2=FALSE, timer3=TRUE
END_FUNCTION_BLOCK

{Test}
METHOD PUBLIC Test_MixedStates
    // ❌ WRONG: Simple mocks cannot create mixed states!
    // All timers will be TRUE or all FALSE
    AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
    
    // ✅ SOLUTION: Use ConfigurableOnDelayMock or IdentifierBasedOnDelayMock instead!
END_METHOD
```

📖 See [SimpleMocks_RealWorld_Test.st](test/SimpleMocks_RealWorld_Test.st) for complete examples.

### Advanced Configurable Mocks

#### ConfigurableOnDelayMock Family

**Best for:** Sequential timers with consistent call order and **different states**

- Supports up to 4 timer instances with **individual states**
- Call-order based identification (1st call = T1, 2nd call = T2, etc.)
- Works with timers having identical durations
- Simple configuration
- **Available for:** OnDelay, OffDelay, TON, TOF

📖 [Full Documentation](docs/ConfigurableOnDelayMock.md)

**Available Mocks:**
- `ConfigurableOnDelayMock` + `ConfigurableOnDelayMockPayload` - For OnDelay
- `ConfigurableOffDelayMock` + `ConfigurableOffDelayMockPayload` - For OffDelay
- `ConfigurableTONMock` + `ConfigurableTONMockPayload` - For TON
- `ConfigurableTOFMock` + `ConfigurableTOFMockPayload` - For TOF

```iecst
payload.ResetCounter();

// Timer 1: elapsed
payload.T1_Enabled := TRUE;
payload.T1_Output := TRUE;
payload.T1_ElapsedTime := T#1s;

// Timer 2: waiting (different state!)
payload.T2_Enabled := TRUE;
payload.T2_Output := FALSE;
payload.T2_ElapsedTime := T#500ms;

// Timer 3: elapsed
payload.T3_Enabled := TRUE;
payload.T3_Output := TRUE;
payload.T3_ElapsedTime := T#5s;

AxUnit.Mocking.Mock(
    mockeeFn := NAME_OF(OnDelay), 
    mockFn := NAME_OF(ConfigurableOnDelayMock),
    payload := payload
);
```

#### IdentifierBasedOnDelayMock Family

**Best for:** Conditional timer logic (e.g., IF mode=1 THEN timer2 ELSE timer3)

- Supports up to 4 timer instances with **individual states**
- Position-based identification with explicit call positions
- Perfect for conditional timer usage
- Duration-independent
- **Available for:** OnDelay, OffDelay, TON, TOF

📖 [Full Documentation](docs/IdentifierBasedOnDelayMock.md)

**Available Mocks:**
- `IdentifierBasedOnDelayMock` + `IdentifierBasedOnDelayMockPayload` - For OnDelay
- `IdentifierBasedOffDelayMock` + `IdentifierBasedOffDelayMockPayload` - For OffDelay
- `IdentifierBasedTONMock` + `IdentifierBasedTONMockPayload` - For TON
- `IdentifierBasedTOFMock` + `IdentifierBasedTOFMockPayload` - For TOF

```iecst
payload.ResetCounter();

// Position 1: Always called
payload.T1_Enabled := TRUE;
payload.T1_CallPosition := 1;
payload.T1_Output := TRUE;

// Position 2: Called in mode 1
payload.T2_Enabled := TRUE;
payload.T2_CallPosition := 2;
payload.T2_Output := FALSE;

// Position 2: Called in mode 2 (same position, different timer!)
payload.T3_Enabled := TRUE;
payload.T3_CallPosition := 2;
payload.T3_Output := TRUE;

AxUnit.Mocking.Mock(
    mockeeFn := NAME_OF(OnDelay), 
    mockFn := NAME_OF(IdentifierBasedOnDelayMock),
    payload := payload
);
```

## Quick Start Examples

### Example 1: Simple Single Timer Mock

```iecst
USING System.Timer;
USING AxUnit.Assert;

NAMESPACE Simatic.Ax.Mocks
    FUNCTION_BLOCK FunctionBlockWhichUsesTimer
        VAR_INPUT
            enable : BOOL;
        END_VAR
        VAR_OUTPUT
            timerStatus : STRING;
        END_VAR
        VAR
            ton : OnDelay;
        END_VAR

        ton(signal := enable, duration := T#10s);

        IF (ton.output) THEN
            timerStatus := 'ELAPSED';
        ELSIF (ton.signal AND NOT ton.output) THEN
            timerStatus := 'RUNNING';
        ELSIF (NOT ton.signal) THEN
            timerStatus := 'IDLE';
        END_IF;
    END_FUNCTION_BLOCK

    {TestFixture}
    CLASS TestFunctionBlockWhichUsesTimer
        VAR
            testInstance : FunctionBlockWhichUsesTimer;
        END_VAR

        {Test}
        METHOD PUBLIC FunctionBlockReturnsElapsedWhenEnabledAndTimeHasElapsed
            // ✅ CORRECT: Single timer - simple mock is perfect
            AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
            testInstance(enable := TRUE);
            Equal(expected := 'ELAPSED', actual := testInstance.timerStatus);
        END_METHOD
    END_CLASS
END_NAMESPACE
```

### Example 2: Multiple Timers with Different States

```iecst
{Test}
METHOD PUBLIC TestMultipleTimersWithDifferentStates
    VAR
        payload : ConfigurableOnDelayMockPayload;
    END_VAR
    
    payload.ResetCounter();
    
    // T1: elapsed
    payload.T1_Enabled := TRUE;
    payload.T1_Output := TRUE;
    payload.T1_ElapsedTime := T#10s;
    
    // T2: waiting (different state!)
    payload.T2_Enabled := TRUE;
    payload.T2_Output := FALSE;
    payload.T2_ElapsedTime := T#5s;
    
    // T3: elapsed
    payload.T3_Enabled := TRUE;
    payload.T3_Output := TRUE;
    payload.T3_ElapsedTime := T#30s;
    
    AxUnit.Mocking.Mock(
        mockeeFn := NAME_OF(OnDelay), 
        mockFn := NAME_OF(ConfigurableOnDelayMock),
        payload := payload
    );
    
    // Test your function block
    myFB(enable1 := TRUE, enable2 := TRUE, enable3 := TRUE);
    
    Equal(expected := TRUE, actual := myFB.OutputT1);
    Equal(expected := FALSE, actual := myFB.OutputT2);  // Different state!
    Equal(expected := TRUE, actual := myFB.OutputT3);
END_METHOD
```

### Example 3: Conditional Timers

```iecst
{Test}
METHOD PUBLIC TestConditionalTimers
    VAR
        payload : IdentifierBasedOnDelayMockPayload;
    END_VAR
    
    payload.ResetCounter();
    
    // Position 1: Always called
    payload.T1_Enabled := TRUE;
    payload.T1_CallPosition := 1;
    payload.T1_Output := TRUE;
    
    // Position 2: Called in mode 1 OR mode 2 (different timers, same position)
    payload.T2_Enabled := TRUE;
    payload.T2_CallPosition := 2;
    payload.T2_Output := TRUE;  // Mode 1 result
    
    AxUnit.Mocking.Mock(
        mockeeFn := NAME_OF(OnDelay), 
        mockFn := NAME_OF(IdentifierBasedOnDelayMock),
        payload := payload
    );
    
    // Test mode 1
    myFB(mode := 1, enable := TRUE);
END_METHOD
```

## Choosing the Right Mock

| Scenario | Recommended Mock |
|----------|------------------|
| **Single timer** | `OnDelayMock_true` / `OnDelayMock_false` ✅ |
| **Multiple timers, all same state** | `OnDelayMock_true` / `OnDelayMock_false` ✅ |
| **Multiple timers, different states** | [`ConfigurableOnDelayMock`](docs/ConfigurableOnDelayMock.md) ✅ |
| **Conditional timer logic (IF/CASE)** | [`IdentifierBasedOnDelayMock`](docs/IdentifierBasedOnDelayMock.md) ✅ |
| **IEC 61131-3 standard timers** | `TON_Mock_true` / `TOF_Mock_false` ✅ |

## Testing Best Practices

### Use Stateless Pattern

Always use the stateless pattern to ensure test isolation:

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

### Reset Counter Before Each Test

For call-order based mocks, always reset the counter:

```iecst
{Test}
METHOD PUBLIC MyTest
    payload.ResetCounter();  // ← Essential!
    // ... configure and test ...
END_METHOD
```

## Documentation

- [ConfigurableOnDelayMock](docs/ConfigurableOnDelayMock.md) - Call-order based mock for multiple timers
- [IdentifierBasedOnDelayMock](docs/IdentifierBasedOnDelayMock.md) - Position-based mock for conditional logic
- [TimerMocks-Overview](docs/TimerMocks-Overview.md) - Complete overview and decision guide

## Tests

All mocks include comprehensive test coverage. See the `test/` directory for examples:

**Simple Mocks:**
- [SimpleMocks_RealWorld_Test.st](test/SimpleMocks_RealWorld_Test.st) - **Real-world examples showing when to use simple mocks**
- [IEC_TON_Mocks_Test.st](test/IEC/Timer/IEC_TON_Mocks_Test.st) - IEC TON timer tests
- [IEC_TOF_Mocks_Test.st](test/IEC/Timer/IEC_TOF_Mocks_Test.st) - IEC TOF timer tests
- [System_OnDelay_Mocks_Test.st](test/System/Timer/System_OnDelay_Mocks_Test.st) - System OnDelay tests
- [System_OffDelay_Mocks_Test.st](test/System/Timer/System_OffDelay_Mocks_Test.st) - System OffDelay tests

**Configurable Mocks:**
- [ConfigurableOnDelayMockTest.st](test/System/Timer/ConfigurableOnDelayMockTest.st) - OnDelay configurable mock
- [ConfigurableOffDelayMockTest.st](test/System/Timer/ConfigurableOffDelayMockTest.st) - OffDelay configurable mock
- [ConfigurableTONMockTest.st](test/IEC/Timer/ConfigurableTONMockTest.st) - TON configurable mock
- [ConfigurableTOFMockTest.st](test/IEC/Timer/ConfigurableTOFMockTest.st) - TOF configurable mock

**Identifier-Based Mocks:**
- [IdentifierBasedOnDelayMockTest.st](test/System/Timer/IdentifierBasedOnDelayMockTest.st) - OnDelay identifier-based mock
- [IdentifierBasedOffDelayMockTest.st](test/System/Timer/IdentifierBasedOffDelayMockTest.st) - OffDelay identifier-based mock
- [IdentifierBasedTONMockTest.st](test/IEC/Timer/IdentifierBasedTONMockTest.st) - TON identifier-based mock
- [IdentifierBasedTOFMockTest.st](test/IEC/Timer/IdentifierBasedTOFMockTest.st) - TOF identifier-based mock

**Real-World Examples:**
- [FooFB_ConfigurableMock_Test.st](test/FooFB_ConfigurableMock_Test.st) - Real-world configurable example
- [FooFB_IdentifierMock_Test.st](test/FooFB_IdentifierMock_Test.st) - Real-world identifier-based example

## Contribution

Thanks for your interest in contributing. Anybody is free to report bugs, unclear documentation, and other problems regarding this repository in the Issues section or, even better, propose changes using Merge Requests.

## License and Legal information

Please read the [Legal information](LICENSE.md)
