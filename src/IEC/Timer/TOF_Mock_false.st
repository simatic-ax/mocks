NAMESPACE Simatic.Ax.Mocks
    /// TOF (Off-Delay Timer) Mock - Always returns FALSE
    /// IEC 61131-3 standard interface
    FUNCTION_BLOCK TOF_Mock_false
        VAR_INPUT
            IN : BOOL;      // Start input
            PT : LTIME;     // Preset time
        END_VAR
        VAR_OUTPUT
            Q : BOOL;       // Output
            ET : LTIME;     // Elapsed time
        END_VAR
        Q := FALSE;
        ET := LTIME#0ms;
    END_FUNCTION_BLOCK
END_NAMESPACE
