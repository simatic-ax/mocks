NAMESPACE Simatic.Ax.Mocks
    /// Identifier-based Timer Mock for System.Timer.OnDelay - up to 4 timer instances
    /// Timers are identified by their call position
    /// This allows testing conditional timer usage without duration dependency
    FUNCTION_BLOCK IdentifierBasedOnDelayMock
        VAR_INPUT
            duration : LTIME;       // Preset duration
            signal : BOOL;          // Input signal
        END_VAR
        VAR_OUTPUT
            output : BOOL;          // Output
            elapsedTime : LTIME;    // Elapsed time
        END_VAR
        VAR_TEMP
            state : REF_TO IdentifierBasedOnDelayMockPayload;
            matched : BOOL;
        END_VAR

        // Get payload configuration
        state ?= AxUnit.Mocking.GetPayload();
        
        IF state = NULL THEN
            // Fallback if no payload is provided
            output := FALSE;
            elapsedTime := LTIME#0ms;
            RETURN;
        END_IF;

        // Increment call counter
        state^.CallCounter := state^.CallCounter + 1;
        
        // Store current call information for debugging
        state^.LastCallDuration := duration;
        state^.LastCallSignal := signal;
        
        matched := FALSE;

        // Check each timer configuration
        // Timer is matched if enabled AND call counter matches the configured call position
        IF state^.T1_Enabled AND state^.CallCounter = state^.T1_CallPosition THEN
            output := state^.T1_Output;
            elapsedTime := state^.T1_ElapsedTime;
            matched := TRUE;
        ELSIF state^.T2_Enabled AND state^.CallCounter = state^.T2_CallPosition THEN
            output := state^.T2_Output;
            elapsedTime := state^.T2_ElapsedTime;
            matched := TRUE;
        ELSIF state^.T3_Enabled AND state^.CallCounter = state^.T3_CallPosition THEN
            output := state^.T3_Output;
            elapsedTime := state^.T3_ElapsedTime;
            matched := TRUE;
        ELSIF state^.T4_Enabled AND state^.CallCounter = state^.T4_CallPosition THEN
            output := state^.T4_Output;
            elapsedTime := state^.T4_ElapsedTime;
            matched := TRUE;
        END_IF;

        // Default if no match found
        IF NOT matched THEN
            output := FALSE;
            elapsedTime := LTIME#0ms;
        END_IF;

    END_FUNCTION_BLOCK

    /// Payload configuration for IdentifierBasedOnDelayMock
    /// Each timer is configured with its expected call position
    /// This allows flexible testing of conditional timer logic
    CLASS IdentifierBasedOnDelayMockPayload IMPLEMENTS AxUnit.Mocking.IPayload
        VAR PUBLIC
            // Internal call counter
            CallCounter : INT := 0;               // Tracks current call number
            
            // Debug information
            LastCallDuration : LTIME := LTIME#0ms;  // Last called duration
            LastCallSignal : BOOL := FALSE;         // Last called signal
            
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
