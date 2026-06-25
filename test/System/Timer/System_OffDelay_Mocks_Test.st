USING AxUnit.Assert;
USING System.Timer;

NAMESPACE Simatic.Ax.Mocks.Tests
    /// Test fixture for System.Timer OffDelay Mocks
    /// Tests both OffDelayMock_false and OffDelayMock_true
    {TestFixture}
    CLASS TestSystem_OffDelay_Mocks
        VAR
            offdelay_false, offdelay_false_stateless : OffDelayMock_false;
            offdelay_true, offdelay_true_stateless : OffDelayMock_true;
        END_VAR

        {TestSetup}
        METHOD PUBLIC TestSetup
            offdelay_false := offdelay_false_stateless;
            offdelay_true := offdelay_true_stateless;
        END_METHOD

        /// Test OffDelayMock_false always returns output=FALSE
        {Test}
        METHOD PUBLIC Test_OffDelay_False_ReturnsAlwaysFalse
            // Call with signal=TRUE
            offdelay_false(signal := TRUE, duration := T#5s);
            
            // Verify output is always FALSE
            Equal(expected := FALSE, actual := offdelay_false.output);
            Equal(expected := T#0ms, actual := offdelay_false.elapsedTime);
        END_METHOD

        /// Test OffDelayMock_false with signal=FALSE
        {Test}
        METHOD PUBLIC Test_OffDelay_False_WithSignalFalse
            // Call with signal=FALSE
            offdelay_false(signal := FALSE, duration := T#10s);
            
            // Verify output is FALSE
            Equal(expected := FALSE, actual := offdelay_false.output);
            Equal(expected := T#0ms, actual := offdelay_false.elapsedTime);
        END_METHOD

        /// Test OffDelayMock_true always returns output=TRUE
        {Test}
        METHOD PUBLIC Test_OffDelay_True_ReturnsAlwaysTrue
            // Call with signal=TRUE
            offdelay_true(signal := TRUE, duration := T#5s);
            
            // Verify output is always TRUE and elapsedTime equals duration
            Equal(expected := TRUE, actual := offdelay_true.output);
            Equal(expected := T#5s, actual := offdelay_true.elapsedTime);
        END_METHOD

        /// Test OffDelayMock_true with signal=FALSE
        {Test}
        METHOD PUBLIC Test_OffDelay_True_WithSignalFalse
            // Call with signal=FALSE
            offdelay_true(signal := FALSE, duration := T#10s);
            
            // Verify output is still TRUE (mock behavior)
            Equal(expected := TRUE, actual := offdelay_true.output);
            Equal(expected := T#10s, actual := offdelay_true.elapsedTime);
        END_METHOD

        /// Test OffDelayMock_true with different duration values
        {Test}
        METHOD PUBLIC Test_OffDelay_True_DifferentDurations
            // Test with 1 second
            offdelay_true(signal := TRUE, duration := T#1s);
            Equal(expected := TRUE, actual := offdelay_true.output);
            Equal(expected := T#1s, actual := offdelay_true.elapsedTime);
            
            // Test with 30 seconds
            offdelay_true(signal := TRUE, duration := T#30s);
            Equal(expected := TRUE, actual := offdelay_true.output);
            Equal(expected := T#30s, actual := offdelay_true.elapsedTime);
        END_METHOD

        /// Test OffDelayMock_false with different duration values
        {Test}
        METHOD PUBLIC Test_OffDelay_False_DifferentDurations
            // Test with 1 second
            offdelay_false(signal := TRUE, duration := T#1s);
            Equal(expected := FALSE, actual := offdelay_false.output);
            Equal(expected := T#0ms, actual := offdelay_false.elapsedTime);
            
            // Test with 30 seconds
            offdelay_false(signal := TRUE, duration := T#30s);
            Equal(expected := FALSE, actual := offdelay_false.output);
            Equal(expected := T#0ms, actual := offdelay_false.elapsedTime);
        END_METHOD

        /// Test OffDelayMock_true with LTIME values
        {Test}
        METHOD PUBLIC Test_OffDelay_True_WithLTIME
            // Test with milliseconds
            offdelay_true(signal := TRUE, duration := LTIME#500ms);
            Equal(expected := TRUE, actual := offdelay_true.output);
            Equal(expected := LTIME#500ms, actual := offdelay_true.elapsedTime);
            
            // Test with minutes
            offdelay_true(signal := TRUE, duration := LTIME#2m);
            Equal(expected := TRUE, actual := offdelay_true.output);
            Equal(expected := LTIME#2m, actual := offdelay_true.elapsedTime);
        END_METHOD
    END_CLASS
END_NAMESPACE
