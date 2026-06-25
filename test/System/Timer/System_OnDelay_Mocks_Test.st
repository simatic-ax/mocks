USING AxUnit.Assert;
USING System.Timer;

NAMESPACE Simatic.Ax.Mocks.Tests
    /// Test fixture for System.Timer OnDelay Mocks
    /// Tests both OnDelayMock_false and OnDelayMock_true
    {TestFixture}
    CLASS TestSystem_OnDelay_Mocks
        VAR
            ondelay_false, ondelay_false_stateless : OnDelayMock_false;
            ondelay_true, ondelay_true_stateless : OnDelayMock_true;
        END_VAR

        {TestSetup}
        METHOD PUBLIC TestSetup
            ondelay_false := ondelay_false_stateless;
            ondelay_true := ondelay_true_stateless;
        END_METHOD

        /// Test OnDelayMock_false always returns output=FALSE
        {Test}
        METHOD PUBLIC Test_OnDelay_False_ReturnsAlwaysFalse
            // Call with signal=TRUE
            ondelay_false(signal := TRUE, duration := T#5s);
            
            // Verify output is always FALSE
            Equal(expected := FALSE, actual := ondelay_false.output);
            Equal(expected := T#0ms, actual := ondelay_false.elapsedTime);
        END_METHOD

        /// Test OnDelayMock_false with signal=FALSE
        {Test}
        METHOD PUBLIC Test_OnDelay_False_WithSignalFalse
            // Call with signal=FALSE
            ondelay_false(signal := FALSE, duration := T#10s);
            
            // Verify output is FALSE
            Equal(expected := FALSE, actual := ondelay_false.output);
            Equal(expected := T#0ms, actual := ondelay_false.elapsedTime);
        END_METHOD

        /// Test OnDelayMock_true always returns output=TRUE
        {Test}
        METHOD PUBLIC Test_OnDelay_True_ReturnsAlwaysTrue
            // Call with signal=TRUE
            ondelay_true(signal := TRUE, duration := T#5s);
            
            // Verify output is always TRUE and elapsedTime equals duration
            Equal(expected := TRUE, actual := ondelay_true.output);
            Equal(expected := T#5s, actual := ondelay_true.elapsedTime);
        END_METHOD

        /// Test OnDelayMock_true with signal=FALSE
        {Test}
        METHOD PUBLIC Test_OnDelay_True_WithSignalFalse
            // Call with signal=FALSE
            ondelay_true(signal := FALSE, duration := T#10s);
            
            // Verify output is still TRUE (mock behavior)
            Equal(expected := TRUE, actual := ondelay_true.output);
            Equal(expected := T#10s, actual := ondelay_true.elapsedTime);
        END_METHOD

        /// Test OnDelayMock_true with different duration values
        {Test}
        METHOD PUBLIC Test_OnDelay_True_DifferentDurations
            // Test with 1 second
            ondelay_true(signal := TRUE, duration := T#1s);
            Equal(expected := TRUE, actual := ondelay_true.output);
            Equal(expected := T#1s, actual := ondelay_true.elapsedTime);
            
            // Test with 30 seconds
            ondelay_true(signal := TRUE, duration := T#30s);
            Equal(expected := TRUE, actual := ondelay_true.output);
            Equal(expected := T#30s, actual := ondelay_true.elapsedTime);
        END_METHOD

        /// Test OnDelayMock_false with different duration values
        {Test}
        METHOD PUBLIC Test_OnDelay_False_DifferentDurations
            // Test with 1 second
            ondelay_false(signal := TRUE, duration := T#1s);
            Equal(expected := FALSE, actual := ondelay_false.output);
            Equal(expected := T#0ms, actual := ondelay_false.elapsedTime);
            
            // Test with 30 seconds
            ondelay_false(signal := TRUE, duration := T#30s);
            Equal(expected := FALSE, actual := ondelay_false.output);
            Equal(expected := T#0ms, actual := ondelay_false.elapsedTime);
        END_METHOD

        /// Test OnDelayMock_true with LTIME values
        {Test}
        METHOD PUBLIC Test_OnDelay_True_WithLTIME
            // Test with milliseconds
            ondelay_true(signal := TRUE, duration := LTIME#500ms);
            Equal(expected := TRUE, actual := ondelay_true.output);
            Equal(expected := LTIME#500ms, actual := ondelay_true.elapsedTime);
            
            // Test with minutes
            ondelay_true(signal := TRUE, duration := LTIME#2m);
            Equal(expected := TRUE, actual := ondelay_true.output);
            Equal(expected := LTIME#2m, actual := ondelay_true.elapsedTime);
        END_METHOD
    END_CLASS
END_NAMESPACE
