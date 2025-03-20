// USING AxUnit;
// USING UserLibrary;

// NAMESPACE mockingpayloadtest

// Function funcMock: int
//     var_temp
//         p : ref_to mypayload;
//     end_var
//     p ?= AxUnit.Mocking.GetPayload();
//     if (p <> null) then 
//         funcMock:=p^.value;
//     end_if;
// End_Function

// //the IPayload interface must be implemented in order for the payload to work
// class mypayload implements AxUnit.Mocking.IPayload
//     var public
//         value: int;
//     end_var
// end_class

// {TestFixture}
// class MYTESTS
//     var
//         payloadInstance: mypayload;
//     end_var

//     {Test}
//     method public Returns123
//         payloadInstance.value := 123;
//         AxUnit.Mocking.Mock(NAME_OF(GetNumber1), NAME_OF(funcMock), payloadInstance);
//         AxUnit.Assert.Equal(expected := 123, actual := GetANumber());

//         payloadInstance.value := 456;
//         AxUnit.Mocking.Mock(NAME_OF(GetNumber1), NAME_OF(funcMock), payloadInstance);
//         AxUnit.Assert.Equal(456, GetANumber());
        
//     end_method
// end_class

// END_NAMESPACE

// NAMESPACE UserLibrary

//     FUNCTION GetANumber : Int
//         GetANumber := GetNumber1();
//     END_FUNCTION

//     FUNCTION GetNumber1 : int
//         GetNumber1 := 1;
//     END_FUNCTION

// END_NAMESPACE