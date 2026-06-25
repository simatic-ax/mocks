NAMESPACE Simatic.Ax.Mocks
    /// Configurable Timer Mock for up to 4 timer instances
    /// Uses payload to configure individual timer states
    /// Can be used for both OnDelay and OffDelay timers
    /// Timers are identified by call order (instance counter)
    FUNCTION_BLOCK ConfigurableTimerMock
        VAR_INPUT
            duration : LTIME;       // Preset duration
            signal : BOOL;          // Input signal
        END_VAR
        VAR_OUTPUT
            output : BOOL;          // Output
            elapsedTime : LTIME;    // Elapsed time
        END_VAR
        VAR_TEMP
            state : REF_TO ConfigurableTimerMockPayload;
        END_VAR

        // Get payload configuration
        state ?= AxUnit.Mocking.GetPayload();
        
        IF state = NULL THEN
            // Fallback if no payload is provided
            output := FALSE;
            elapsedTime := LTIME#0ms;
            RETURN;
        END_IF;

        // Increment call counter to identify timer instance
        state^.CallCounter := state^.CallCounter + 1;
        
        // Match timer by call order and apply configured state
        IF state^.CallCounter = 1 AND state^.T1_Enabled THEN
            output := state^.T1_Output;
            elapsedTime := state^.T1_ElapsedTime;
        ELSIF state^.CallCounter = 2 AND state^.T2_Enabled THEN
            output := state^.T2_Output;
            elapsedTime := state^.T2_ElapsedTime;
        ELSIF state^.CallCounter = 3 AND state^.T3_Enabled THEN
            output := state^.T3_Output;
            elapsedTime := state^.T3_ElapsedTime;
        ELSIF state^.CallCounter = 4 AND state^.T4_Enabled THEN
            output := state^.T4_Output;
            elapsedTime := state^.T4_ElapsedTime;
        ELSE
            // No matching timer configuration or counter overflow
            output := FALSE;
            elapsedTime := LTIME#0ms;
        END_IF;

    END_FUNCTION_BLOCK

    /// Payload configuration for ConfigurableTimerMock
    /// Allows configuration of up to 4 timer instances
    /// Timers are identified by their call order (1st call = T1, 2nd call = T2, etc.)
    CLASS ConfigurableTimerMockPayload IMPLEMENTS AxUnit.Mocking.IPayload
        VAR PUBLIC
            // Internal call counter to track timer instances
            CallCounter : INT := 0;             // Tracks which timer instance is being called
            
            // Timer 1 configuration (1st timer call)
            T1_Enabled : BOOL := FALSE;         // Enable Timer 1
            T1_Output : BOOL := FALSE;          // Desired output for Timer 1
            T1_ElapsedTime : LTIME := LTIME#0ms; // Elapsed time for Timer 1
            
            // Timer 2 configuration (2nd timer call)
            T2_Enabled : BOOL := FALSE;         // Enable Timer 2
            T2_Output : BOOL := FALSE;          // Desired output for Timer 2
            T2_ElapsedTime : LTIME := LTIME#0ms; // Elapsed time for Timer 2
            
            // Timer 3 configuration (3rd timer call)
            T3_Enabled : BOOL := FALSE;         // Enable Timer 3
            T3_Output : BOOL := FALSE;          // Desired output for Timer 3
            T3_ElapsedTime : LTIME := LTIME#0ms; // Elapsed time for Timer 3
            
            // Timer 4 configuration (4th timer call)
            T4_Enabled : BOOL := FALSE;         // Enable Timer 4
            T4_Output : BOOL := FALSE;          // Desired output for Timer 4
            T4_ElapsedTime : LTIME := LTIME#0ms; // Elapsed time for Timer 4
        END_VAR
        
        /// Reset call counter - call this before each test cycle
        METHOD PUBLIC ResetCounter
            CallCounter := 0;
        END_METHOD
    END_CLASS
END_NAMESPACE
