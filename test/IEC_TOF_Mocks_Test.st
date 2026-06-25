USING AxUnit.Assert;

NAMESPACE Simatic.Ax.Mocks.Tests
    /// Test fixture for IEC TOF (Off-Delay Timer) Mocks
    /// Tests both TOF_Mock_false and TOF_Mock_true
    {TestFixture}
    CLASS TestIEC_TOF_Mocks
        VAR
            tof_false, tof_false_stateless : TOF_Mock_false;
            tof_true, tof_true_stateless : TOF_Mock_true;
        END_VAR

        {TestSetup}
        METHOD PUBLIC TestSetup
            tof_false := tof_false_stateless;
            tof_true := tof_true_stateless;
        END_METHOD

        /// Test TOF_Mock_false always returns Q=FALSE
        {Test}
        METHOD PUBLIC Test_TOF_False_ReturnsAlwaysFalse
            // Call with IN=TRUE
            tof_false(IN := TRUE, PT := T#5s);
            
            // Verify output is always FALSE
            Equal(expected := FALSE, actual := tof_false.Q);
            Equal(expected := T#0ms, actual := tof_false.ET);
        END_METHOD

        /// Test TOF_Mock_false with IN=FALSE
        {Test}
        METHOD PUBLIC Test_TOF_False_WithInputFalse
            // Call with IN=FALSE
            tof_false(IN := FALSE, PT := T#10s);
            
            // Verify output is FALSE
            Equal(expected := FALSE, actual := tof_false.Q);
            Equal(expected := T#0ms, actual := tof_false.ET);
        END_METHOD

        /// Test TOF_Mock_true always returns Q=TRUE
        {Test}
        METHOD PUBLIC Test_TOF_True_ReturnsAlwaysTrue
            // Call with IN=TRUE
            tof_true(IN := TRUE, PT := T#5s);
            
            // Verify output is always TRUE and ET equals PT
            Equal(expected := TRUE, actual := tof_true.Q);
            Equal(expected := T#5s, actual := tof_true.ET);
        END_METHOD

        /// Test TOF_Mock_true with IN=FALSE
        {Test}
        METHOD PUBLIC Test_TOF_True_WithInputFalse
            // Call with IN=FALSE
            tof_true(IN := FALSE, PT := T#10s);
            
            // Verify output is still TRUE (mock behavior)
            Equal(expected := TRUE, actual := tof_true.Q);
            Equal(expected := T#10s, actual := tof_true.ET);
        END_METHOD

        /// Test TOF_Mock_true with different PT values
        {Test}
        METHOD PUBLIC Test_TOF_True_DifferentPresetTimes
            // Test with 1 second
            tof_true(IN := TRUE, PT := T#1s);
            Equal(expected := TRUE, actual := tof_true.Q);
            Equal(expected := T#1s, actual := tof_true.ET);
            
            // Test with 30 seconds
            tof_true(IN := TRUE, PT := T#30s);
            Equal(expected := TRUE, actual := tof_true.Q);
            Equal(expected := T#30s, actual := tof_true.ET);
        END_METHOD

        /// Test TOF_Mock_false with different PT values
        {Test}
        METHOD PUBLIC Test_TOF_False_DifferentPresetTimes
            // Test with 1 second
            tof_false(IN := TRUE, PT := T#1s);
            Equal(expected := FALSE, actual := tof_false.Q);
            Equal(expected := T#0ms, actual := tof_false.ET);
            
            // Test with 30 seconds
            tof_false(IN := TRUE, PT := T#30s);
            Equal(expected := FALSE, actual := tof_false.Q);
            Equal(expected := T#0ms, actual := tof_false.ET);
        END_METHOD
    END_CLASS
END_NAMESPACE
