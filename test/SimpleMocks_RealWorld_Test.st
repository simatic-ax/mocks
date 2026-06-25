USING AxUnit.Assert;
USING System.Timer;

NAMESPACE Simatic.Ax.Mocks.Tests
    /// Example function block with a single OnDelay timer
    /// Demonstrates typical single-timer usage
    FUNCTION_BLOCK SingleTimerController
        VAR_INPUT
            enable : BOOL;
        END_VAR
        VAR_OUTPUT
            status : STRING;
            isReady : BOOL;
        END_VAR
        VAR
            startupTimer : OnDelay;
        END_VAR
        
        // Single timer for startup delay
        startupTimer(signal := enable, duration := T#5s);
        
        IF startupTimer.output THEN
            status := 'READY';
            isReady := TRUE;
        ELSIF enable AND NOT startupTimer.output THEN
            status := 'STARTING';
            isReady := FALSE;
        ELSE
            status := 'IDLE';
            isReady := FALSE;
        END_IF;
    END_FUNCTION_BLOCK

    /// Example function block with multiple timers that should ALL have the same state
    /// Use case: All timers must be elapsed before proceeding
    FUNCTION_BLOCK MultiTimerAllSameState
        VAR_INPUT
            enable : BOOL;
        END_VAR
        VAR_OUTPUT
            allReady : BOOL;
            status : STRING;
        END_VAR
        VAR
            timer1 : OnDelay;
            timer2 : OnDelay;
            timer3 : OnDelay;
        END_VAR
        
        // All timers must be elapsed for system to be ready
        timer1(signal := enable, duration := T#5s);
        timer2(signal := enable, duration := T#10s);
        timer3(signal := enable, duration := T#15s);
        
        // Check if ALL timers are elapsed
        IF timer1.output AND timer2.output AND timer3.output THEN
            allReady := TRUE;
            status := 'ALL_READY';
        ELSE
            allReady := FALSE;
            status := 'WAITING';
        END_IF;
    END_FUNCTION_BLOCK

    /// Test fixture for simple timer mocks with realistic function blocks
    /// Demonstrates when simple mocks should be used
    {TestFixture}
    CLASS TestSimpleMocks_RealWorld
        VAR
            singleTimer, singleTimerStateless : SingleTimerController;
            multiTimerSame, multiTimerSameStateless : MultiTimerAllSameState;
        END_VAR

        {TestSetup}
        METHOD PUBLIC TestSetup
            singleTimer := singleTimerStateless;
            multiTimerSame := multiTimerSameStateless;
        END_METHOD

        /// ✅ CORRECT USAGE: Single timer - test elapsed state
        {Test}
        METHOD PUBLIC Test_SingleTimer_Elapsed
            // Mock single timer as elapsed
            AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
            
            singleTimer(enable := TRUE);
            
            Equal(expected := 'READY', actual := singleTimer.status);
            Equal(expected := TRUE, actual := singleTimer.isReady);
        END_METHOD

        /// ✅ CORRECT USAGE: Single timer - test waiting state
        {Test}
        METHOD PUBLIC Test_SingleTimer_Waiting
            // Mock single timer as not elapsed
            AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_false));
            
            singleTimer(enable := TRUE);
            
            Equal(expected := 'STARTING', actual := singleTimer.status);
            Equal(expected := FALSE, actual := singleTimer.isReady);
        END_METHOD

        /// ✅ CORRECT USAGE: Multiple timers ALL elapsed (same state)
        {Test}
        METHOD PUBLIC Test_MultipleTimers_AllElapsed
            // Mock ALL timers as elapsed
            AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
            
            multiTimerSame(enable := TRUE);
            
            Equal(expected := TRUE, actual := multiTimerSame.allReady);
            Equal(expected := 'ALL_READY', actual := multiTimerSame.status);
        END_METHOD

        /// ✅ CORRECT USAGE: Multiple timers ALL waiting (same state)
        {Test}
        METHOD PUBLIC Test_MultipleTimers_AllWaiting
            // Mock ALL timers as not elapsed
            AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_false));
            
            multiTimerSame(enable := TRUE);
            
            Equal(expected := FALSE, actual := multiTimerSame.allReady);
            Equal(expected := 'WAITING', actual := multiTimerSame.status);
        END_METHOD

        /// ❌ LIMITATION EXAMPLE: Cannot test mixed states with simple mocks
        /// For this scenario, use ConfigurableTimerMock or IdentifierBasedTimerMock
        {Test}
        METHOD PUBLIC Test_Limitation_CannotTestMixedStates
            // Simple mocks set ALL timers to the same state
            // Cannot test: timer1=TRUE, timer2=FALSE, timer3=TRUE
            
            // This test demonstrates the limitation:
            AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock_true));
            
            multiTimerSame(enable := TRUE);
            
            // All timers will be TRUE (cannot have mixed states)
            Equal(expected := TRUE, actual := multiTimerSame.allReady);
            
            // ⚠️ If you need mixed states, use ConfigurableTimerMock instead!
        END_METHOD
    END_CLASS

    /// Additional example: Emergency stop with single timer
    FUNCTION_BLOCK EmergencyStopController
        VAR_INPUT
            emergencyStop : BOOL;
        END_VAR
        VAR_OUTPUT
            safeToRestart : BOOL;
            message : STRING;
        END_VAR
        VAR
            cooldownTimer : OffDelay;
        END_VAR
        
        // Off-delay timer for cooldown after emergency stop
        cooldownTimer(signal := NOT emergencyStop, duration := T#30s);
        
        IF cooldownTimer.output THEN
            safeToRestart := TRUE;
            message := 'SAFE_TO_RESTART';
        ELSE
            safeToRestart := FALSE;
            message := 'COOLDOWN_ACTIVE';
        END_IF;
    END_FUNCTION_BLOCK

    /// Test fixture for OffDelay simple mocks
    {TestFixture}
    CLASS TestSimpleMocks_OffDelay
        VAR
            emergencyStop, emergencyStopStateless : EmergencyStopController;
        END_VAR

        {TestSetup}
        METHOD PUBLIC TestSetup
            emergencyStop := emergencyStopStateless;
        END_METHOD

        /// ✅ CORRECT USAGE: Single OffDelay timer - cooldown complete
        {Test}
        METHOD PUBLIC Test_EmergencyStop_CooldownComplete
            // Mock timer as elapsed (safe to restart)
            AxUnit.Mocking.Mock(NAME_OF(OffDelay), NAME_OF(OffDelayMock_true));
            
            emergencyStop(emergencyStop := FALSE);
            
            Equal(expected := TRUE, actual := emergencyStop.safeToRestart);
            Equal(expected := 'SAFE_TO_RESTART', actual := emergencyStop.message);
        END_METHOD

        /// ✅ CORRECT USAGE: Single OffDelay timer - cooldown active
        {Test}
        METHOD PUBLIC Test_EmergencyStop_CooldownActive
            // Mock timer as not elapsed (still cooling down)
            AxUnit.Mocking.Mock(NAME_OF(OffDelay), NAME_OF(OffDelayMock_false));
            
            emergencyStop(emergencyStop := FALSE);
            
            Equal(expected := FALSE, actual := emergencyStop.safeToRestart);
            Equal(expected := 'COOLDOWN_ACTIVE', actual := emergencyStop.message);
        END_METHOD
    END_CLASS
END_NAMESPACE
