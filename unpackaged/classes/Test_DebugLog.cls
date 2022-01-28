/*------------------------------------------------------------
Author:        Miguel Coimbra (Salesforce)
Description:   Generic Class providing a service for logging messages, error or any other information
               to a Debug Log Object for troubleshooting purposes
Test Class:    Test_DebugLog
History
	190917	   Created class
------------------------------------------------------------*/
@isTest
private class Test_DebugLog {

    @isTest static void myTestLogMessage (){
        Test.startTest();
        DebugLog dl = new DebugLog();
        DebugLog.addInfo('This is an Info');
        DebugLog.addError('This is an error');
        DebugLog.addInfo('This is an Info', 'with objectId');
        DebugLog.addError('This is an error', 'with objectId');
        System.assertEquals([Select count() from DebugLog__c], 4);
        DebugLog.addInfoFuture('This is an Info logged asynchronously');
        DebugLog.addErrorFuture('This is an error logged asynchronously');
        Test.StopTest();
    }

    @isTest static void myTestTruncatedLogMessage (){
        Test.startTest();
        DebugLog dl = new DebugLog();
        String errMsg = '';
        for (integer i=0; i < 33000; i++) errMsg += '!';
        DebugLog.addInfo(errMsg);
        DebugLog.addError(errMsg);
        DebugLog.addInfoFuture(errMsg);
        DebugLog.addErrorFuture(errMsg);
        System.assertEquals(32768, [SELECT Message__c FROM DebugLog__c LIMIT 1].Message__c.length(), 'Expected truncated to 32768 chars');
        Test.StopTest();
    }

    @isTest static void myTestLogException (){
        try{
            Exception ex ;
            throw ex;
        } catch (exception e){
            Test.startTest();
            DebugLog.addException(e, 'Error on Test Coverage');
            Test.StopTest();
            System.assertEquals([Select count() from DebugLog__c], 1);
        }
    }
}