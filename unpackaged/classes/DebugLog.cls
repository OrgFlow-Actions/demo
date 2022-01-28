/*------------------------------------------------------------
Author:        Miguel Coimbra (Salesforce)
Description:   Generic Class providing a service for logging messages, error or any other information
               to a Debug Log Object for troubleshooting purposes
Test Class:    TestDebugLog
History
	190917	   Created class
------------------------------------------------------------*/
global without sharing class DebugLog {
    private final static String INFO 		= 'Info';
    private final static String ERROR		= 'Error';
    private final static String FATAL		= 'Fatal';

    global DebugLog(){}

    public static void addInfo(String description){
        createLog(DebugLog.INFO, description);
    }

    public static void addInfo(String description, String objectId){
        createLog(DebugLog.INFO, description, objectId);
    }

    public static void addError(String description){
        createLog(DebugLog.ERROR, description);
    }

    public static void addError(String description, String objectId){
        createLog(DebugLog.ERROR, description, objectId);
    }

    public static void addException(Exception ex, String Comments){
        createException(DebugLog.FATAL,''+ex.getCause(), ''+ex.getLineNumber(), ''+ex.getMessage(), ''+ex.getStackTraceString(), ''+ex.getTypeName(), '' +comments);
    }

    @future
    public static void addInfoFuture(String description){
        createLog(DebugLog.INFO, description);
    }

    @future
    public static void addErrorFuture(String description){
        createLog(DebugLog.ERROR, description);
    }

    private static void createLog(String severity, String description){
        DebugLog__c dl = new DebugLog__c();
        dl.Severity__c = severity;
        dl.Message__c = description.left(32768);
        dl.DateTime__c = System.now();
        Database.Saveresult saveresult = Database.insert(dl);
    }

    private static void createLog(String severity, String description, String objectId){
        DebugLog__c dl = new DebugLog__c();
        dl.Severity__c = severity;
        dl.Message__c = description.left(32768);
        dl.DateTime__c = System.now();
        dl.ObjectId__c = objectId.left(18);
        Database.Saveresult saveresult = Database.insert(dl);
    }

    private static void createException(String severity, String cause, String linenumber, String message, String stacktracestring, String typename, String Comments){
        DebugLog__c dl = new DebugLog__c();
        dl.Severity__c = severity;
        dl.Cause__c = cause.left(32768);
        dl.LineNumber__c = linenumber;
        dl.Message__c = message.left(32768);
        dl.StackTraceString__c = stacktracestring.left(32768);
        dl.TypeName__c = typename.left(32768);
        dl.Comments__c = comments.left(32768);
        dl.DateTime__c = System.now();
        Database.Saveresult saveresult = Database.insert(dl);
    }
}