USING AxUnit.Assert;
USING System.Timer;

NAMESPACE Simatic.Ax.Mocks
    /// Test fixture for FbWithThreeTimers using IdentifierBasedTimerMock
    /// This demonstrates position-based timer mocking with explicit call positions
    /// Uses stateless pattern to ensure test isolation
    {TestFixture}
    CLASS TestFbWithThreeTimers_IdentifierMock
        VAR
            myFB, myFBStateless : FbWithThreeTimers;
            payload, payloadStateless : IdentifierBasedTimerMockPayload;
        END_VAR

        /// Setup method to reset instances before each test
        {TestSetup}
        METHOD PUBLIC TestSetup
            payload := payloadStateless;
            myFB := myFBStateless;
        END_METHOD

        /// Test scenario: T1 elapsed, T2 waiting, T3 elapsed
        /// Using explicit call positions
        {Test}
        METHOD PUBLIC Test_T1_Elapsed_T2_Waiting_T3_Elapsed
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure timers by explicit call position
            // T1 at position 1 - elapsed
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;  // 1st call
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#10s;
            
            // T2 at position 2 - waiting
            payload.T2_Enabled := TRUE;
            payload.T2_CallPosition := 2;  // 2nd call
            payload.T2_Output := FALSE;
            payload.T2_ElapsedTime := T#5s;
            
            // T3 at position 3 - elapsed
            payload.T3_Enabled := TRUE;
            payload.T3_CallPosition := 3;  // 3rd call
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#30s;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute function block
            myFB.SignalT1 := TRUE;
            myFB.SignalT2 := TRUE;
            myFB.SignalT3 := TRUE;
            myFB();
            
            // Verify results
            Equal(expected := TRUE, actual := myFB.OutputT1);
            Equal(expected := FALSE, actual := myFB.OutputT2);
            Equal(expected := TRUE, actual := myFB.OutputT3);
        END_METHOD

        /// Test scenario: All timers elapsed
        {Test}
        METHOD PUBLIC Test_AllTimersElapsed
            payload.ResetCounter();
            
            // All timers elapsed at their respective positions
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#10s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_CallPosition := 2;
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#20s;
            
            payload.T3_Enabled := TRUE;
            payload.T3_CallPosition := 3;
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#30s;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute
            myFB.SignalT1 := TRUE;
            myFB.SignalT2 := TRUE;
            myFB.SignalT3 := TRUE;
            myFB();
            
            // Verify all outputs are TRUE
            Equal(expected := TRUE, actual := myFB.OutputT1);
            Equal(expected := TRUE, actual := myFB.OutputT2);
            Equal(expected := TRUE, actual := myFB.OutputT3);
        END_METHOD

        /// Test scenario: All timers waiting
        {Test}
        METHOD PUBLIC Test_AllTimersWaiting
            payload.ResetCounter();
            
            // All timers waiting
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;
            payload.T1_Output := FALSE;
            payload.T1_ElapsedTime := T#3s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_CallPosition := 2;
            payload.T2_Output := FALSE;
            payload.T2_ElapsedTime := T#7s;
            
            payload.T3_Enabled := TRUE;
            payload.T3_CallPosition := 3;
            payload.T3_Output := FALSE;
            payload.T3_ElapsedTime := T#15s;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute
            myFB.SignalT1 := TRUE;
            myFB.SignalT2 := TRUE;
            myFB.SignalT3 := TRUE;
            myFB();
            
            // Verify all outputs are FALSE
            Equal(expected := FALSE, actual := myFB.OutputT1);
            Equal(expected := FALSE, actual := myFB.OutputT2);
            Equal(expected := FALSE, actual := myFB.OutputT3);
        END_METHOD

        /// Test scenario: Only T2 configured at position 2
        {Test}
        METHOD PUBLIC Test_OnlyT2Configured
            payload.ResetCounter();
            
            // Only configure T2 at position 2
            payload.T1_Enabled := FALSE;  // Position 1 - not configured
            
            payload.T2_Enabled := TRUE;   // Position 2 - configured
            payload.T2_CallPosition := 2;
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#20s;
            
            payload.T3_Enabled := FALSE;  // Position 3 - not configured
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute
            myFB.SignalT1 := TRUE;
            myFB.SignalT2 := TRUE;
            myFB.SignalT3 := TRUE;
            myFB();
            
            // Verify: T1 and T3 default to FALSE, T2 is TRUE
            Equal(expected := FALSE, actual := myFB.OutputT1);
            Equal(expected := TRUE, actual := myFB.OutputT2);
            Equal(expected := FALSE, actual := myFB.OutputT3);
        END_METHOD

        /// Test scenario: Non-sequential positions (demonstrating flexibility)
        /// Configure T1 at position 3, T3 at position 1 (swapped)
        {Test}
        METHOD PUBLIC Test_NonSequentialPositions
            payload.ResetCounter();
            
            // Swap positions: T3 at position 1, T1 at position 3
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 3;  // T1 configured for 3rd call
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#10s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_CallPosition := 2;  // T2 at 2nd call (normal)
            payload.T2_Output := FALSE;
            payload.T2_ElapsedTime := T#5s;
            
            payload.T3_Enabled := TRUE;
            payload.T3_CallPosition := 1;  // T3 configured for 1st call
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#30s;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute
            myFB.SignalT1 := TRUE;
            myFB.SignalT2 := TRUE;
            myFB.SignalT3 := TRUE;
            myFB();
            
            // Verify: 
            // 1st call (T1 in code) gets T3 config -> TRUE
            // 2nd call (T2 in code) gets T2 config -> FALSE
            // 3rd call (T3 in code) gets T1 config -> TRUE
            Equal(expected := TRUE, actual := myFB.OutputT1);   // Gets T3 config
            Equal(expected := FALSE, actual := myFB.OutputT2);  // Gets T2 config
            Equal(expected := TRUE, actual := myFB.OutputT3);   // Gets T1 config
        END_METHOD

        /// Test scenario: Partial elapsed times
        /// Demonstrates setting specific elapsed times for each timer
        {Test}
        METHOD PUBLIC Test_PartialElapsedTimes
            payload.ResetCounter();
            
            // Configure with specific elapsed times
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;
            payload.T1_Output := FALSE;  // Not elapsed yet
            payload.T1_ElapsedTime := T#7s;  // 7 of 10 seconds
            
            payload.T2_Enabled := TRUE;
            payload.T2_CallPosition := 2;
            payload.T2_Output := FALSE;  // Not elapsed yet
            payload.T2_ElapsedTime := T#15s;  // 15 of 20 seconds
            
            payload.T3_Enabled := TRUE;
            payload.T3_CallPosition := 3;
            payload.T3_Output := TRUE;  // Elapsed
            payload.T3_ElapsedTime := T#30s;  // Full 30 seconds
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(IdentifierBasedTimerMock),
                payload := payload
            );
            
            // Execute
            myFB.SignalT1 := TRUE;
            myFB.SignalT2 := TRUE;
            myFB.SignalT3 := TRUE;
            myFB();
            
            // Verify outputs
            Equal(expected := FALSE, actual := myFB.OutputT1);  // 7s < 10s
            Equal(expected := FALSE, actual := myFB.OutputT2);  // 15s < 20s
            Equal(expected := TRUE, actual := myFB.OutputT3);   // 30s = 30s
        END_METHOD
    END_CLASS
END_NAMESPACE
