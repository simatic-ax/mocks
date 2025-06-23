USING System.Timer;
USING AxUnit.Assert;

NAMESPACE Simatic.Ax.Mocks
    /// Function block that uses an OnDelay timer to set a status string.
    /// Input: enable - Enables the timer when TRUE.
    /// Returns: Sets timerStatus to 'IDLE', 'RUNNING', or 'ELAPSED' based on timer state.
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

    /// Test fixture for FunctionBlockWhichUsesTimer.
    {TestFixture}
    CLASS TestFunctionBlockWhichUsesTimer
        VAR
            testInstance : FunctionBlockWhichUsesTimer;
        END_VAR

        /// Tests that timerStatus is 'IDLE' when enable is FALSE.
        {Test}
        METHOD PUBLIC FunctionBlockReturnsIdleWhenNotEnabled
            testInstance(enable := FALSE);
            Equal(expected := 'IDLE', actual := testInstance.timerStatus);
        END_METHOD

        /// Tests that timerStatus is 'RUNNING' when enabled and time has not elapsed.
        {Test}
        METHOD PUBLIC FunctionBlockReturnsRunningWhenEnabledAndTimeIsNotElapsed
            testInstance(enable := TRUE);
            Equal(expected := 'RUNNING', actual := testInstance.timerStatus);
        END_METHOD

        /// Tests that timerStatus is 'ELAPSED' when enabled and time has elapsed (using mock).
        {Test}
        METHOD PUBLIC FunctionBlockReturnsElapsedWhenEnabledAndTimeHasElapsed
            // This line creates a mock for the 'OnDelay' function, replacing it with 'OnDelayMock_true'.
            // It's used in unit testing to simulate the behavior of 'OnDelay' without running its real implementation.
            AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));  
            testInstance(enable := TRUE);
            Equal(expected := 'ELAPSED', actual := testInstance.timerStatus);
        END_METHOD
    END_CLASS
END_NAMESPACE