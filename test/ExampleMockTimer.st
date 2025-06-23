USING System.Timer;
USING AxUnit.Assert;

NAMESPACE Simatic.Ax.Mocks
    FUNCTION_BLOCK FunctionBlockWhichUsesTimer
        VAR_INPUT
            enable : BOOL;        
        END_VAR
        VAR_OUTPUT
            timerStatus : STRING;
        END_VAR
        
        VAR
            ton : OnDelay;
        END_VAR
        
        ton(signal := enable, duration := T#10s);

        IF (ton.output) THEN
            timerStatus := 'ELAPSED';
        ELSIF (ton.signal AND NOT ton.output) THEN
            timerStatus := 'RUNNING';
        ELSIF (NOT ton.signal) THEN
            timerStatus := 'IDLE';
        END_IF;
        ;
    END_FUNCTION_BLOCK

    {TestFixture}
    CLASS TestFunctionBlockWhichUsesTimer
        VAR
            testInstance : FunctionBlockWhichUsesTimer;
        END_VAR

        {Test}
        METHOD PUBLIC FunctionBlockReturnsIdleWhenNotEnabled
            testInstance(enable := FALSE);
            Equal(expected := 'ELAPSED', actual := testInstance.timerStatus);
        END_METHOD

        
        {Test}
        METHOD PUBLIC FunctionBlockReturnsRunningWhenEnabledAndTimeIsNotElapsed
            testInstance(enable := TRUE);
            Equal(expected := 'RUNNING', actual := testInstance.timerStatus);
        END_METHOD

        {Test}
        METHOD PUBLIC FunctionBlockReturnsElapsedWhenEnabledAndTimeHasElapsed
            testInstance(enable := TRUE);
            Equal(expected := 'ELAPSED', actual := testInstance.timerStatus);
        END_METHOD
    END_CLASS
END_NAMESPACE