USING AxUnit.Assert;
USING System.Timer;
NAMESPACE Simatic.Ax.Mocks

    FUNCTION_BLOCK FbWithThreeTimers
        VAR_INPUT
            SignalT1 : BOOL;
            SignalT2 : BOOL;
            SignalT3 : BOOL;
        END_VAR
        VAR_OUTPUT
            OutputT1 : BOOL;
            OutputT2 : BOOL;
            OutputT3 : BOOL;
        END_VAR
        VAR
            T1 : OnDelay;
            T2 : OnDelay;
            T3 : OnDelay;
        END_VAR
        T1(Signal := SignalT1, Duration := LTIME#10S, Output => OutputT1);
        T2(Signal := SignalT2, Duration := LTIME#20S, Output => OutputT2);
        T3(Signal := SignalT3, Duration := LTIME#30S, Output => OutputT3);
    END_FUNCTION_BLOCK
END_NAMESPACE
