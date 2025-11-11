# Mocks

## Description

This package provide some predefined mocks for the AXUnit testing framework which you can use for your own tests.

## Install this package

```cli
apax add @simatic-ax/mocks
```

## Namespace
```
Simatic.Ax.Mocks;
```

## Mocks in this package

|Name|Signal|
|-|-|
|OffDelayMock_false | output = FALSE |
|OffDelayMock_true  | output = TRUE  |
|OnDelayMock_false  | output = FALSE |
|OnDelayMock_true   | output = TRUE  |
|OnDelayMockWithTwoTimers   | output = TRUE  |

## Example: How to mock a Timer like OnDelay

You can use the provided mocks to simulate timer behavior in your unit tests.  
Below is an example of how to mock the `OnDelay` timer using `AxUnit.Mocking.Mock` and verify the behavior of your function block or class under test.

```iecst
USING System.Timer;
USING AxUnit.Assert;

NAMESPACE Simatic.Ax.Mocks
    /// Function block that uses an OnDelay timer to set a status string.
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
        ;
    END_FUNCTION_BLOCK

    {TestFixture}
    CLASS TestFunctionBlockWhichUsesTimer
        VAR
            testInstance : FunctionBlockWhichUsesTimer;
        END_VAR

        /// Tests that timerStatus is 'ELAPSED' when enabled and time has elapsed (using mock).
        {Test}
        METHOD PUBLIC FunctionBlockReturnsElapsedWhenEnabledAndTimeHasElapsed
            // Mock the OnDelay timer to always return output = TRUE
            AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
            testInstance(enable := TRUE);
            Equal(expected := 'ELAPSED', actual := testInstance.timerStatus);
        END_METHOD
    END_CLASS
END_NAMESPACE
```

## Markdownlint-cli

This workspace will be checked by the [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli) (there is also documented ho to install the tool) tool in the CI workflow automatically.  
To avoid, that the CI workflow fails because of the markdown linter, you can check all markdown files locally by running the markdownlint with:

```sh
markdownlint **/*.md --fix
```

## Contribution

Thanks for your interest in contributing. Anybody is free to report bugs, unclear documentation, and other problems regarding this repository in the Issues section or, even better, is free to propose any changes to this repository using Merge Requests.

## License and Legal information

Please read the [Legal information](LICENSE.md)
