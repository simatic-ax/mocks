USING System.Timer;
USING AxUnit.Assert;

NAMESPACE Simatic.Ax.Mocks
    /// Example function block with conditional timer usage
    /// Depending on mode, different timers are called at different positions
    FUNCTION_BLOCK ConditionalTimerExample
        VAR_INPUT
            mode : INT;         // 1 = use T1+T2, 2 = use T1+T3
            enable : BOOL;
        END_VAR
        VAR_OUTPUT
            status : STRING;
        END_VAR
        VAR
            timer1 : OnDelay;   // Always used at position 1
            timer2 : OnDelay;   // Used at position 2 in mode 1
            timer3 : OnDelay;   // Used at position 2 in mode 2
        END_VAR
        
        // Timer 1 is always called first (position 1)
        timer1(signal := enable, duration := T#1s);
        
        IF mode = 1 THEN
            // Mode 1: Timer 2 is called at position 2
            timer2(signal := enable, duration := T#2s);
            
            IF timer1.output AND timer2.output THEN
                status := 'MODE1_BOTH_ELAPSED';
            ELSIF timer1.output THEN
                status := 'MODE1_T1_ELAPSED';
            ELSE
                status := 'MODE1_WAITING';
            END_IF;
            
        ELSIF mode = 2 THEN
            // Mode 2: Timer 3 is called at position 2
            timer3(signal := enable, duration := T#3s);
            
            IF timer1.output AND timer3.output THEN
                status := 'MODE2_BOTH_ELAPSED';
            ELSIF timer1.output THEN
                status := 'MODE2_T1_ELAPSED';
            ELSE
                status := 'MODE2_WAITING';
            END_IF;
        END_IF;
    END_FUNCTION_BLOCK

    /// Test fixture demonstrating IdentifierBasedTimerMock with conditional timers
    {TestFixture}
    CLASS TestIdentifierBasedTimerMock
        VAR
            testInstance, testInstanceStateless : ConditionalTimerExample;
            testInstanceMulti, testInstanceMultiStateless : MultiTimerFunctionBlock;
            payload, payloadStateless : IdentifierBasedTimerMockPayload;
        END_VAR

        {TestSetup}
        METHOD PUBLIC TestSetup
            payload := payloadStateless;
            testInstance := testInstanceStateless;
            testInstanceMulti := testInstanceMultiStateless;
        END_METHOD

        /// Test Mode 1: T1 at position 1, T2 at position 2
        {Test}
        METHOD PUBLIC TestMode1_BothTimersElapsed
            payload.ResetCounter();
            
            // Timer 1: Position 1 (always first call)
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;  // 1st call
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#1s;
            
            // Timer 2: Position 2 (second call in mode 1)
            payload.T2_Enabled := TRUE;
            payload.T2_CallPosition := 2;  // 2nd call
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#2s;

            // Timer 3: not called in mode 1
            payload.T3_Enabled := FALSE;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute in mode 1
            testInstance(mode := 1, enable := TRUE);
            
            // Verify both timers elapsed
            Equal(expected := 'MODE1_BOTH_ELAPSED', actual := testInstance.status);
        END_METHOD

        /// Test Mode 1: T1 elapsed, T2 waiting
        {Test}
        METHOD PUBLIC TestMode1_OnlyT1Elapsed
            payload.ResetCounter();
            
            // Timer 1: Position 1, elapsed
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#1s;
            
            // Timer 2: Position 2, not elapsed
            payload.T2_Enabled := TRUE;
            payload.T2_CallPosition := 2;
            payload.T2_Output := FALSE;
            payload.T2_ElapsedTime := T#500ms;
            
            // Timer 3: not called in mode 1
            payload.T3_Enabled := FALSE;

            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute in mode 1
            testInstance(mode := 1, enable := TRUE);
            
            // Verify only T1 elapsed
            Equal(expected := 'MODE1_T1_ELAPSED', actual := testInstance.status);
        END_METHOD

        /// Test Mode 2: T1 at position 1, T3 at position 2
        {Test}
        METHOD PUBLIC TestMode2_BothTimersElapsed
            payload.ResetCounter();
            
            // Timer 1: Position 1 (always first call)
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;  // 1st call
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#1s;

            // Timer 2: not called in mode 2
            payload.T2_Enabled := FALSE;

            // Timer 3: Position 2 (second call in mode 2)
            payload.T3_Enabled := TRUE;
            payload.T3_CallPosition := 2;  // 2nd call
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#3s;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute in mode 2
            testInstance(mode := 2, enable := TRUE);
            
            // Verify both timers elapsed
            Equal(expected := 'MODE2_BOTH_ELAPSED', actual := testInstance.status);
        END_METHOD

        /// Test Mode 2: T1 elapsed, T3 waiting
        {Test}
        METHOD PUBLIC TestMode2_OnlyT1Elapsed
            payload.ResetCounter();
            
            // Timer 1: Position 1, elapsed
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#1s;
            
            // Timer 2: not called in mode 2
            payload.T2_Enabled := FALSE;


            // Timer 3: Position 2, not elapsed
            payload.T3_Enabled := TRUE;
            payload.T3_CallPosition := 2;
            payload.T3_Output := FALSE;
            payload.T3_ElapsedTime := T#1500ms;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute in mode 2
            testInstance(mode := 2, enable := TRUE);
            
            // Verify only T1 elapsed
            Equal(expected := 'MODE2_T1_ELAPSED', actual := testInstance.status);
        END_METHOD

        /// Test with 3 sequential timers (no conditional logic)
        {Test}
        METHOD PUBLIC TestSequentialTimers
            payload.ResetCounter();
            
            // Configure 3 timers at positions 1, 2, 3
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#1s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_CallPosition := 2;
            payload.T2_Output := FALSE;
            payload.T2_ElapsedTime := T#500ms;
            
            payload.T3_Enabled := TRUE;
            payload.T3_CallPosition := 3;
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#5s;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay),
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute
            testInstanceMulti(enable1 := TRUE, enable2 := TRUE, enable3 := TRUE);
            
            // Verify results
            Equal(expected := 'T1_ELAPSED', actual := testInstanceMulti.status1);
            Equal(expected := 'T2_WAITING', actual := testInstanceMulti.status2);
            Equal(expected := 'T3_ELAPSED', actual := testInstanceMulti.status3);
        END_METHOD
    END_CLASS
END_NAMESPACE
