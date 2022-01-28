/*------------------------------------------------------------------------------------------------------------------------
Author        : Salesforce Services
Company       : Salesforce
Description   : Test class for DummyClass
Inputs        : None
History       :
------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class Test_ProcessBuilderBypassHelper {
    @isTest
    public static void TestDummyMethod () {
        DoNothingPB.doNothing();
        system.assert(true);
    }
}