NAMESPACE Simatic.Ax.Mocks
    /// Identifier-based Timer Mock for IEC.Timer.TON - up to 4 timer instances
    /// Timers are identified by their call position
    /// This allows testing conditional timer usage without duration dependency
    FUNCTION_BLOCK IdentifierBasedTONMock
        VAR_INPUT
            PT : LTIME;             // Preset time
            IN : BOOL;              // Input signal
        END_VAR
        VAR_OUTPUT
            Q : BOOL;               // Output
            ET : LTIME;             // Elapsed time
        END_VAR
        VAR_TEMP
            state : REF_TO IdentifierBasedTONMockPayload;
            matched : BOOL;
        END_VAR

        // Get payload configuration
        state ?= AxUnit.Mocking.GetPayload();
        
        IF state = NULL THEN
            // Fallback if no payload is provided
            Q := FALSE;
            ET := LTIME#0ms;
            RETURN;
        END_IF;

        // Increment call counter
        state^.CallCounter := state^.CallCounter + 1;
        
        // Store current call information for debugging
        state^.LastCallPT := PT;
        state^.LastCallIN := IN;
        
        matched := FALSE;

        // Check each timer configuration
        // Timer is matched if enabled AND call counter matches the configured call position
        IF state^.T1_Enabled AND state^.CallCounter = state^.T1_CallPosition THEN
            Q := state^.T1_Output;
            ET := state^.T1_ElapsedTime;
            matched := TRUE;
        ELSIF state^.T2_Enabled AND state^.CallCounter = state^.T2_CallPosition THEN
            Q := state^.T2_Output;
            ET := state^.T2_ElapsedTime;
            matched := TRUE;
        ELSIF state^.T3_Enabled AND state^.CallCounter = state^.T3_CallPosition THEN
            Q := state^.T3_Output;
            ET := state^.T3_ElapsedTime;
            matched := TRUE;
        ELSIF state^.T4_Enabled AND state^.CallCounter = state^.T4_CallPosition THEN
            Q := state^.T4_Output;
            ET := state^.T4_ElapsedTime;
            matched := TRUE;
        END_IF;

        // Default if no match found
        IF NOT matched THEN
            Q := FALSE;
            ET := LTIME#0ms;
        END_IF;

    END_FUNCTION_BLOCK

    /// Payload configuration for IdentifierBasedTONMock
    /// Each timer is configured with its expected call position
    /// This allows flexible testing of conditional timer logic
    CLASS IdentifierBasedTONMockPayload IMPLEMENTS AxUnit.Mocking.IPayload
        VAR PUBLIC
            // Internal call counter
            CallCounter : INT := 0;               // Tracks current call number
            
            // Debug information
            LastCallPT : LTIME := LTIME#0ms;      // Last called preset time
            LastCallIN : BOOL := FALSE;           // Last called input signal
            
            // Timer 1 configuration
            T1_Enabled : BOOL := FALSE;           // Enable Timer 1
            T1_CallPosition : INT := 1;           // Expected call position (1st, 2nd, 3rd, etc.)
            T1_Output : BOOL := FALSE;            // Desired output for Timer 1
            T1_ElapsedTime : LTIME := LTIME#0ms;  // Elapsed time for Timer 1
            
            // Timer 2 configuration
            T2_Enabled : BOOL := FALSE;           // Enable Timer 2
            T2_CallPosition : INT := 2;           // Expected call position
            T2_Output : BOOL := FALSE;            // Desired output for Timer 2
            T2_ElapsedTime : LTIME := LTIME#0ms;  // Elapsed time for Timer 2
            
            // Timer 3 configuration
            T3_Enabled : BOOL := FALSE;           // Enable Timer 3
            T3_CallPosition : INT := 3;           // Expected call position
            T3_Output : BOOL := FALSE;            // Desired output for Timer 3
            T3_ElapsedTime : LTIME := LTIME#0ms;  // Elapsed time for Timer 3
            
            // Timer 4 configuration
            T4_Enabled : BOOL := FALSE;           // Enable Timer 4
            T4_CallPosition : INT := 4;           // Expected call position
            T4_Output : BOOL := FALSE;            // Desired output for Timer 4
            T4_ElapsedTime : LTIME := LTIME#0ms;  // Elapsed time for Timer 4
        END_VAR
        
        /// Reset call counter - call this before each test cycle
        METHOD PUBLIC ResetCounter
            CallCounter := 0;
        END_METHOD
    END_CLASS
END_NAMESPACE
