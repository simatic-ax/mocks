USING AxUnit.Assert;

NAMESPACE Simatic.Ax.Mocks
    /// Example function block that uses multiple TOF timers
    FUNCTION_BLOCK MultiTOFFunctionBlock
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
            timer1 : TOF_Mock_true;
            timer2 : TOF_Mock_true;
            timer3 : TOF_Mock_true;
        END_VAR
        
        // Timer 1: 1 second delay
        timer1(IN := enable1, PT := T#1s);
        IF timer1.Q THEN
            status1 := 'T1_ON';
        ELSE
            status1 := 'T1_OFF';
        END_IF;
        
        // Timer 2: 2 second delay
        timer2(IN := enable2, PT := T#2s);
        IF timer2.Q THEN
            status2 := 'T2_ON';
        ELSE
            status2 := 'T2_OFF';
        END_IF;
        
        // Timer 3: 5 second delay
        timer3(IN := enable3, PT := T#5s);
        IF timer3.Q THEN
            status3 := 'T3_ON';
        ELSE
            status3 := 'T3_OFF';
        END_IF;
    END_FUNCTION_BLOCK

    /// Test fixture demonstrating ConfigurableTOFMock usage
    {TestFixture}
    CLASS TestConfigurableTOFMock
        VAR
            testInstance, testInstanceStateless : MultiTOFFunctionBlock;
            payload, payloadStateless : ConfigurableTOFMockPayload;
        END_VAR

        /// Setup method to reset instances before each test
        {TestSetup}
        METHOD PUBLIC TestSetup
            payload := payloadStateless;
            testInstance := testInstanceStateless;
        END_METHOD

        /// Test with Timer 1 ON, Timer 2 OFF, Timer 3 ON
        /// Timers are identified by call order: 1st call = T1, 2nd call = T2, 3rd call = T3
        {Test}
        METHOD PUBLIC TestMultipleTimersWithDifferentStates
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure payload: T1=TRUE, T2=FALSE, T3=TRUE (by call order)
            payload.T1_Enabled := TRUE;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#0ms;
            
            payload.T2_Enabled := TRUE;
            payload.T2_Output := FALSE;
            payload.T2_ElapsedTime := T#2s;
            
            payload.T3_Enabled := TRUE;
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#0ms;
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(TOF_Mock_true),
                mockFn := NAME_OF(ConfigurableTOFMock),
                payload := payload
            );
            
            // Execute function block
            // Timer calls happen in order: timer1 (1st call), timer2 (2nd call), timer3 (3rd call)
            testInstance(enable1 := FALSE, enable2 := FALSE, enable3 := FALSE);
            
            // Verify results
            Equal(expected := 'T1_ON', actual := testInstance.status1);
            Equal(expected := 'T2_OFF', actual := testInstance.status2);
            Equal(expected := 'T3_ON', actual := testInstance.status3);
        END_METHOD

        /// Test with all timers OFF (delay elapsed)
        {Test}
        METHOD PUBLIC TestAllTimersOff
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure payload: All timers OFF
            payload.T1_Enabled := TRUE;
            payload.T1_Output := FALSE;
            payload.T1_ElapsedTime := T#1s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_Output := FALSE;
            payload.T2_ElapsedTime := T#2s;
            
            payload.T3_Enabled := TRUE;
            payload.T3_Output := FALSE;
            payload.T3_ElapsedTime := T#5s;
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(TOF_Mock_true),
                mockFn := NAME_OF(ConfigurableTOFMock),
                payload := payload
            );
            
            // Execute function block
            testInstance(enable1 := FALSE, enable2 := FALSE, enable3 := FALSE);
            
            // Verify results
            Equal(expected := 'T1_OFF', actual := testInstance.status1);
            Equal(expected := 'T2_OFF', actual := testInstance.status2);
            Equal(expected := 'T3_OFF', actual := testInstance.status3);
        END_METHOD

        /// Test with only Timer 2 enabled (2nd call)
        {Test}
        METHOD PUBLIC TestOnlyTimer2Enabled
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure payload: Only T2 enabled and ON
            payload.T1_Enabled := FALSE;  // 1st call returns FALSE
            
            payload.T2_Enabled := TRUE;   // 2nd call returns TRUE
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#0ms;
            
            payload.T3_Enabled := FALSE;  // 3rd call returns FALSE
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(TOF_Mock_true),
                mockFn := NAME_OF(ConfigurableTOFMock),
                payload := payload
            );
            
            // Execute function block
            testInstance(enable1 := FALSE, enable2 := FALSE, enable3 := FALSE);
            
            // Verify results
            Equal(expected := 'T1_OFF', actual := testInstance.status1); // 1st call: not enabled
            Equal(expected := 'T2_ON', actual := testInstance.status2);  // 2nd call: enabled and TRUE
            Equal(expected := 'T3_OFF', actual := testInstance.status3); // 3rd call: not enabled
        END_METHOD

        /// Test with all timers ON (signal still active or delay not elapsed)
        {Test}
        METHOD PUBLIC TestAllTimersOn
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure payload: All timers ON
            payload.T1_Enabled := TRUE;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#0ms;
            
            payload.T2_Enabled := TRUE;
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#0ms;
            
            payload.T3_Enabled := TRUE;
            payload.T3_Output := TRUE;
            payload.T3_ElapsedTime := T#0ms;
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(TOF_Mock_true),
                mockFn := NAME_OF(ConfigurableTOFMock),
                payload := payload
            );
            
            // Execute function block
            testInstance(enable1 := TRUE, enable2 := TRUE, enable3 := TRUE);
            
            // Verify results
            Equal(expected := 'T1_ON', actual := testInstance.status1);
            Equal(expected := 'T2_ON', actual := testInstance.status2);
            Equal(expected := 'T3_ON', actual := testInstance.status3);
        END_METHOD
    END_CLASS
END_NAMESPACE
