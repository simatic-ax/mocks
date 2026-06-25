USING AxUnit.Assert;
USING System.Timer;

NAMESPACE Simatic.Ax.Mocks
    /// Test fixture for FbWithThreeTimers using ConfigurableTimerMock
    /// This demonstrates call-order based timer mocking
    /// Uses stateless pattern to ensure test isolation
    {TestFixture}
    CLASS TestFbWithThreeTimers_ConfigurableMock
        VAR
            myFB, myFBStateless : FbWithThreeTimers;
            payload, payloadStateless : ConfigurableOnDelayMockPayload;
        END_VAR

        /// Setup method to reset instances before each test
        {TestSetup}
        METHOD PUBLIC TestSetup
            payload := payloadStateless;
            myFB := myFBStateless;
        END_METHOD

        /// Test scenario: T1 elapsed, T2 waiting, T3 elapsed
        {Test}
        METHOD PUBLIC Test_T1_Elapsed_T2_Waiting_T3_Elapsed
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure timers by call order
            // T1 is 1st call - elapsed
            payload.T1_Enabled := TRUE;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#10s;
            
            // T2 is 2nd call - waiting
            payload.T2_Enabled := TRUE;
            payload.T2_Output := FALSE;
            payload.T2_ElapsedTime := T#5s;
            
            // T3 is 3rd call - elapsed
            payload.T3_Enabled := TRUE;
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#30s;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(ConfigurableOnDelayMock),
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
            
            // All timers elapsed
            payload.T1_Enabled := TRUE;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#10s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#20s;
            
            payload.T3_Enabled := TRUE;
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#30s;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(ConfigurableOnDelayMock),
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
            payload.T1_Output := FALSE;
            payload.T1_ElapsedTime := T#3s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_Output := FALSE;
            payload.T2_ElapsedTime := T#7s;
            
            payload.T3_Enabled := TRUE;
            payload.T3_Output := FALSE;
            payload.T3_ElapsedTime := T#15s;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(ConfigurableOnDelayMock),
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

        /// Test scenario: Only T2 enabled (others disabled)
        {Test}
        METHOD PUBLIC Test_OnlyT2Enabled
            payload.ResetCounter();
            
            // Only T2 enabled at position 2
            payload.T1_Enabled := FALSE;  // 1st call - not configured
            
            payload.T2_Enabled := TRUE;   // 2nd call - configured
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#20s;
            
            payload.T3_Enabled := FALSE;  // 3rd call - not configured
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(ConfigurableOnDelayMock),
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

        /// Test scenario: Mixed signals - some enabled, some disabled
        {Test}
        METHOD PUBLIC Test_MixedSignals
            payload.ResetCounter();
            
            // Configure all timers as elapsed
            payload.T1_Enabled := TRUE;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#10s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#20s;
            
            payload.T3_Enabled := TRUE;
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#30s;
            
            // Apply mock
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(OnDelay), 
                mockFn := NAME_OF(ConfigurableOnDelayMock),
                payload := payload
            );
            
            // Execute with mixed signals
            myFB.SignalT1 := TRUE;   // Enabled
            myFB.SignalT2 := FALSE;  // Disabled
            myFB.SignalT3 := TRUE;   // Enabled
            myFB();
            
            // Verify: Mock returns configured values regardless of signal
            // (This is the mock behavior - it ignores the signal input)
            Equal(expected := TRUE, actual := myFB.OutputT1);
            Equal(expected := TRUE, actual := myFB.OutputT2);
            Equal(expected := TRUE, actual := myFB.OutputT3);
        END_METHOD
    END_CLASS
END_NAMESPACE
