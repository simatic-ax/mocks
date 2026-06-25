USING AxUnit.Assert;

NAMESPACE Simatic.Ax.Mocks.Tests
    /// Test fixture for IEC TON (On-Delay Timer) Mocks
    /// Tests both TON_Mock_false and TON_Mock_true
    {TestFixture}
    CLASS TestIEC_TON_Mocks
        VAR
            ton_false, ton_false_stateless : TON_Mock_false;
            ton_true, ton_true_stateless : TON_Mock_true;
        END_VAR

        {TestSetup}
        METHOD PUBLIC TestSetup
            ton_false := ton_false_stateless;
            ton_true := ton_true_stateless;
        END_METHOD

        /// Test TON_Mock_false always returns Q=FALSE
        {Test}
        METHOD PUBLIC Test_TON_False_ReturnsAlwaysFalse
            // Call with IN=TRUE
            ton_false(IN := TRUE, PT := T#5s);
            
            // Verify output is always FALSE
            Equal(expected := FALSE, actual := ton_false.Q);
            Equal(expected := T#0ms, actual := ton_false.ET);
        END_METHOD

        /// Test TON_Mock_false with IN=FALSE
        {Test}
        METHOD PUBLIC Test_TON_False_WithInputFalse
            // Call with IN=FALSE
            ton_false(IN := FALSE, PT := T#10s);
            
            // Verify output is FALSE
            Equal(expected := FALSE, actual := ton_false.Q);
            Equal(expected := T#0ms, actual := ton_false.ET);
        END_METHOD

        /// Test TON_Mock_true always returns Q=TRUE
        {Test}
        METHOD PUBLIC Test_TON_True_ReturnsAlwaysTrue
            // Call with IN=TRUE
            ton_true(IN := TRUE, PT := T#5s);
            
            // Verify output is always TRUE and ET equals PT
            Equal(expected := TRUE, actual := ton_true.Q);
            Equal(expected := T#5s, actual := ton_true.ET);
        END_METHOD

        /// Test TON_Mock_true with IN=FALSE
        {Test}
        METHOD PUBLIC Test_TON_True_WithInputFalse
            // Call with IN=FALSE
            ton_true(IN := FALSE, PT := T#10s);
            
            // Verify output is still TRUE (mock behavior)
            Equal(expected := TRUE, actual := ton_true.Q);
            Equal(expected := T#10s, actual := ton_true.ET);
        END_METHOD

        /// Test TON_Mock_true with different PT values
        {Test}
        METHOD PUBLIC Test_TON_True_DifferentPresetTimes
            // Test with 1 second
            ton_true(IN := TRUE, PT := T#1s);
            Equal(expected := TRUE, actual := ton_true.Q);
            Equal(expected := T#1s, actual := ton_true.ET);
            
            // Test with 30 seconds
            ton_true(IN := TRUE, PT := T#30s);
            Equal(expected := TRUE, actual := ton_true.Q);
            Equal(expected := T#30s, actual := ton_true.ET);
        END_METHOD

        /// Test TON_Mock_false with different PT values
        {Test}
        METHOD PUBLIC Test_TON_False_DifferentPresetTimes
            // Test with 1 second
            ton_false(IN := TRUE, PT := T#1s);
            Equal(expected := FALSE, actual := ton_false.Q);
            Equal(expected := T#0ms, actual := ton_false.ET);
            
            // Test with 30 seconds
            ton_false(IN := TRUE, PT := T#30s);
            Equal(expected := FALSE, actual := ton_false.Q);
            Equal(expected := T#0ms, actual := ton_false.ET);
        END_METHOD
    END_CLASS
END_NAMESPACE
