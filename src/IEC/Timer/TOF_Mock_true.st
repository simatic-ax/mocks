NAMESPACE Simatic.Ax.Mocks
    /// TOF (Off-Delay Timer) Mock - Always returns TRUE
    /// IEC 61131-3 standard interface
    FUNCTION_BLOCK TOF_Mock_true
        VAR_INPUT
            IN : BOOL;      // Start input
            PT : LTIME;     // Preset time
        END_VAR
        VAR_OUTPUT
            Q : BOOL;       // Output
            ET : LTIME;     // Elapsed time
        END_VAR
        Q := TRUE;
        ET := PT;
    END_FUNCTION_BLOCK
END_NAMESPACE
