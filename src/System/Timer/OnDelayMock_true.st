NAMESPACE Simatic.Ax.Mocks
    /// On-Delay Timer Mock - Always returns TRUE
    /// System.Timer interface (signal/duration)
    FUNCTION_BLOCK OnDelayMock_true
        VAR_INPUT
            duration : LTIME;       // Preset duration
            signal : BOOL;          // Input signal
        END_VAR
        VAR_OUTPUT
            output : BOOL;          // Output
            elapsedTime : LTIME;    // Elapsed time
        END_VAR
        output := TRUE;
        elapsedTime := duration;
    END_FUNCTION_BLOCK
END_NAMESPACE