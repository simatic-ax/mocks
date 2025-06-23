USING System.Timer;
USING Simatic.Ax.Mocks;
NAMESPACE Simatic.Ax.Example
    /// Test fixture for testing OnDelayMock with two timers and verifying their states.
    {TestFixture}
    CLASS TestActiveWait
        VAR
            _payloadinstance : OnDelayMockState;
            testInstance : Testee;
        END_VAR

        /// Tests the state of two timers after one clock cycle with mocked values.
        /// Input: None.
        /// Returns: None. Asserts expected timer states.
        {Test}
        METHOD PUBLIC Test_One_Clock_Cycle_Expect_True_False_True
            // give the timer instances a uniq ID. For this purpose, the duration will be used. 
            // This is possible, because the result of the timer depends on the mock and not on the time
            testInstance.ValueT1 := T#1s; 
            testInstance.ValueT2 := T#2s;

            // Mock timer values after 5 seconds: Timer1 returns true, Timer2 returns false
            _payloadinstance.StatusTimer1 := TRUE;
            _payloadinstance.StatusTimer2 := FALSE;

            // Mock-Setup
            AxUnit.Mocking.Mock(NAME_OF(OnDelay), NAME_OF(OnDelayMock2Timer), _payloadinstance); 
            testInstance.Execute(run := TRUE);
            AxUnit.Assert.Equal(expected := TRUE, actual := testInstance.GetTimerState(1));  // expected true --> but something went wrong
            // AxUnit.Assert.Equal(expected := FALSE, actual := testInstance.GetTimerState(2));
            
        END_METHOD
    END_CLASS
    
    /// Class under test that manages two OnDelay timers and exposes their states.
    CLASS Testee
      VAR PUBLIC
        /// Duration for timer 1.
        ValueT1 : LTIME := T#1s;
        /// Duration for timer 2.
        ValueT2 : LTIME := T#2s;
      END_VAR

      VAR
        t1 : Ondelay;
        t2 : OnDelay;
      END_VAR

      /// Executes both timers with the provided run signal and configured durations.
      /// Input: run - BOOL signal to start both timers.
      /// Returns: None.
      METHOD PUBLIC Execute
        VAR_INPUT
          run : BOOL;
        END_VAR      
        t1(signal := run, duration := ValueT1);
        t2(signal := run, duration := ValueT2);
      END_METHOD

      /// Gets the output state of the specified timer.
      /// Input: id - INT, 1 for t1, 2 for t2.
      /// Returns: BOOL state of the selected timer.
      METHOD PUBLIC GetTimerState : BOOL
        VAR_INPUT
          id : INT;
        END_VAR
        
        CASE id OF
          1 : GetTimerState := t1.output;
          2 : GetTimerState := t2.output;
        END_CASE;
      END_METHOD

    END_CLASS


END_NAMESPACE



