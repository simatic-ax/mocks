USING System.Timer;
USING AxUnit.Assert;

NAMESPACE Simatic.Ax.Mocks
    /// Example function block that uses multiple OnDelay timers
    FUNCTION_BLOCK MultiTimerFunctionBlock
        VAR_INPUT
            enable1 : BOOL;
            enable2 : BOOL;
            enable3 : BOOL;
        END_VAR
        VAR_OUTPUT
            status1 : STRING;
            status2 : STRING;
            status3 : STRING;
        END_VAR
        VAR
            timer1 : OnDelay;
            timer2 : OnDelay;
            timer3 : OnDelay;
        END_VAR
        
        // Timer 1: 1 second delay
        timer1(signal := enable1, duration := T#1s);
        IF timer1.output THEN
            status1 := 'T1_ELAPSED';
        ELSE
            status1 := 'T1_WAITING';
        END_IF;
        
        // Timer 2: 2 second delay
        timer2(signal := enable2, duration := T#2s);
        IF timer2.output THEN
            status2 := 'T2_ELAPSED';
        ELSE
            status2 := 'T2_WAITING';
        END_IF;
        
        // Timer 3: 5 second delay
        timer3(signal := enable3, duration := T#5s);
        IF timer3.output THEN
            status3 := 'T3_ELAPSED';
        ELSE
            status3 := 'T3_WAITING';
        END_IF;
    END_FUNCTION_BLOCK

    /// Test fixture demonstrating ConfigurableTimerMock usage
    {TestFixture}
    CLASS TestConfigurableTimerMock
        VAR
            testInstance, testInstanceStateless : MultiTimerFunctionBlock;
            payload, payloadStateless : ConfigurableTimerMockPayload;
        END_VAR

        /// Setup method to reset instances before each test
        {TestSetup}
        METHOD PUBLIC TestSetup
            payload := payloadStateless;
            testInstance := testInstanceStateless;
        END_METHOD

        /// Test with Timer 1 elapsed, Timer 2 waiting, Timer 3 elapsed
        /// Timers are identified by call order: 1st call = T1, 2nd call = T2, 3rd call = T3
        {Test}
        METHOD PUBLIC TestMultipleTimersWithDifferentStates
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure payload: T1=TRUE, T2=FALSE, T3=TRUE (by call order)
            payload.T1_Enabled := TRUE;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#1s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_Output := FALSE;
            payload.T2_ElapsedTime := T#500ms;
            
            payload.T3_Enabled := TRUE;
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#5s;
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay),
                mockFn := NAME_OF(ConfigurableTimerMock),
                payload := payload
            );
            
            // Execute function block
            // Timer calls happen in order: timer1 (1st call), timer2 (2nd call), timer3 (3rd call)
            testInstance(enable1 := TRUE, enable2 := TRUE, enable3 := TRUE);
            
            // Verify results
            Equal(expected := 'T1_ELAPSED', actual := testInstance.status1);
            Equal(expected := 'T2_WAITING', actual := testInstance.status2);
            Equal(expected := 'T3_ELAPSED', actual := testInstance.status3);
        END_METHOD

        /// Test with all timers elapsed
        {Test}
        METHOD PUBLIC TestAllTimersElapsed
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure payload: All timers elapsed
            payload.T1_Enabled := TRUE;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#1s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#2s;
            
            payload.T3_Enabled := TRUE;
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#5s;
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay),
                mockFn := NAME_OF(ConfigurableTimerMock),
                payload := payload
            );
            
            // Execute function block
            testInstance(enable1 := TRUE, enable2 := TRUE, enable3 := TRUE);
            
            // Verify results
            Equal(expected := 'T1_ELAPSED', actual := testInstance.status1);
            Equal(expected := 'T2_ELAPSED', actual := testInstance.status2);
            Equal(expected := 'T3_ELAPSED', actual := testInstance.status3);
        END_METHOD

        /// Test with only Timer 2 enabled (2nd call)
        {Test}
        METHOD PUBLIC TestOnlyTimer2Enabled
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure payload: Only T2 enabled and elapsed
            payload.T1_Enabled := FALSE;  // 1st call returns FALSE
            
            payload.T2_Enabled := TRUE;   // 2nd call returns TRUE
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#2s;
            
            payload.T3_Enabled := FALSE;  // 3rd call returns FALSE
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay),
                mockFn := NAME_OF(ConfigurableTimerMock),
                payload := payload
            );
            
            // Execute function block
            testInstance(enable1 := TRUE, enable2 := TRUE, enable3 := TRUE);
            
            // Verify results
            Equal(expected := 'T1_WAITING', actual := testInstance.status1); // 1st call: not enabled
            Equal(expected := 'T2_ELAPSED', actual := testInstance.status2); // 2nd call: enabled and TRUE
            Equal(expected := 'T3_WAITING', actual := testInstance.status3); // 3rd call: not enabled
        END_METHOD
    END_CLASS
END_NAMESPACE
