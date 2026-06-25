USING AxUnit.Assert;

NAMESPACE Simatic.Ax.Mocks
    /// Example function block with conditional TOF timer usage
    FUNCTION_BLOCK ConditionalTOFFunctionBlock
        VAR_INPUT
            mode : INT;  // 1, 2, or 3 to select which timer to use
        END_VAR
        VAR_OUTPUT
            result : STRING;
        END_VAR
        VAR
            timer1 : TOF_Mock_true;
            timer2 : TOF_Mock_true;
            timer3 : TOF_Mock_true;
        END_VAR
        
        // Conditional timer usage based on mode
        IF mode = 1 THEN
            timer1(IN := FALSE, PT := T#1s);
            IF timer1.Q THEN
                result := 'MODE1_ON';
            ELSE
                result := 'MODE1_OFF';
            END_IF;
        ELSIF mode = 2 THEN
            timer2(IN := FALSE, PT := T#2s);
            IF timer2.Q THEN
                result := 'MODE2_ON';
            ELSE
                result := 'MODE2_OFF';
            END_IF;
        ELSIF mode = 3 THEN
            timer3(IN := FALSE, PT := T#5s);
            IF timer3.Q THEN
                result := 'MODE3_ON';
            ELSE
                result := 'MODE3_OFF';
            END_IF;
        ELSE
            result := 'INVALID_MODE';
        END_IF;
    END_FUNCTION_BLOCK

    /// Test fixture demonstrating IdentifierBasedTOFMock usage
    {TestFixture}
    CLASS TestIdentifierBasedTOFMock
        VAR
            testInstance, testInstanceStateless : ConditionalTOFFunctionBlock;
            payload, payloadStateless : IdentifierBasedTOFMockPayload;
        END_VAR

        /// Setup method to reset instances before each test
        {TestSetup}
        METHOD PUBLIC TestSetup
            payload := payloadStateless;
            testInstance := testInstanceStateless;
        END_METHOD

        /// Test Mode 1 - Timer at position 1 should be ON
        {Test}
        METHOD PUBLIC TestMode1TimerOn
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure Timer 1 (1st call position) to be ON
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#0ms;
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(TOF_Mock_true),
                mockFn := NAME_OF(IdentifierBasedTOFMock),
                payload := payload
            );
            
            // Execute function block in mode 1
            testInstance(mode := 1);
            
            // Verify result
            Equal(expected := 'MODE1_ON', actual := testInstance.result);
        END_METHOD

        /// Test Mode 2 - Timer at position 1 should be OFF
        {Test}
        METHOD PUBLIC TestMode2TimerOff
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure Timer 1 (1st call position) to be OFF
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;
            payload.T1_Output := FALSE;
            payload.T1_ElapsedTime := T#2s;
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(TOF_Mock_true),
                mockFn := NAME_OF(IdentifierBasedTOFMock),
                payload := payload
            );
            
            // Execute function block in mode 2
            testInstance(mode := 2);
            
            // Verify result
            Equal(expected := 'MODE2_OFF', actual := testInstance.result);
        END_METHOD

        /// Test Mode 3 - Timer at position 1 should be ON
        {Test}
        METHOD PUBLIC TestMode3TimerOn
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure Timer 1 (1st call position) to be ON
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;
            payload.T1_Output := TRUE;
            payload.T1_ElapsedTime := T#0ms;
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(TOF_Mock_true),
                mockFn := NAME_OF(IdentifierBasedTOFMock),
                payload := payload
            );
            
            // Execute function block in mode 3
            testInstance(mode := 3);
            
            // Verify result
            Equal(expected := 'MODE3_ON', actual := testInstance.result);
        END_METHOD

        /// Test with multiple configured timers - only matching position is used
        {Test}
        METHOD PUBLIC TestMultipleConfiguredTimers
            // Reset counter before test
            payload.ResetCounter();
            
            // Configure multiple timers with different call positions
            payload.T1_Enabled := TRUE;
            payload.T1_CallPosition := 1;
            payload.T1_Output := FALSE;
            payload.T1_ElapsedTime := T#1s;
            
            payload.T2_Enabled := TRUE;
            payload.T2_CallPosition := 2;
            payload.T2_Output := TRUE;
            payload.T2_ElapsedTime := T#0ms;
            
            // Apply mock with payload
            AxUnit.Mocking.Mock(
                mockeeFn := NAME_OF(TOF_Mock_true),
                mockFn := NAME_OF(IdentifierBasedTOFMock),
                payload := payload
            );
            
            // Execute function block in mode 2 (should match T1 at position 1, but T1 is at position 1)
            // Since mode 2 calls timer2, it's the 1st call, so T1 matches
            testInstance(mode := 2);
            
            // Verify result - T1 configuration is used (position 1, OFF)
            Equal(expected := 'MODE2_OFF', actual := testInstance.result);
        END_METHOD
    END_CLASS
END_NAMESPACE
