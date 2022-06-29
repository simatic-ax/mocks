USING System.Timer;
USING Simatic.Ax.Mocks;
NAMESPACE Simatic.Ax.Example
    {TestFixture}
    CLASS TestActiveWait
        VAR
            _state : OnDelayMockState;
            testInstance : Testee;
        END_VAR

        {Test}
        METHOD PUBLIC Test_One_Clock_Cycle_Expect_True_False_True
            // give the timer instances a uniq ID. For this purpose, the duration will be used. 
            // This is possible, because the result of the timer depends on the mock and not on the time
            testInstance.ValueT1 := T#1s; 
            testInstance.ValueT2 := T#2s;

            // Mock timer values after 5 seconds: Timer1 returns true, Timer2 returns false
            _state.StatusTimer1 := TRUE;
            _state.StatusTimer2 := FALSE;

            // Mock-Setup
            AxUnit.Mocking.Mock('System.Timer.OnDelay', NAME_OF(OnDelayMock2Timer), THIS._state); 
            testInstance.Execute(run := TRUE);
            AxUnit.Assert.Equal(TRUE, testInstance.GetTimerState(1));
            AxUnit.Assert.Equal(FALSE, testInstance.GetTimerState(2));
            
        END_METHOD
    END_CLASS
    
    CLASS Testee
      VAR PUBLIC
        ValueT1 : LTIME := T#5s;
        ValueT2 : LTIME := T#10s;
      END_VAR

      VAR
        t1 : Ondelay;
        t2 : OnDelay;
      END_VAR

      METHOD PUBLIC Execute
        VAR_INPUT
          run : BOOL;
        END_VAR      
        t1(signal := run, duration := ValueT1);
        t2(signal := run, duration := ValueT2);
      END_METHOD

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



