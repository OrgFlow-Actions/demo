public class MyTaskController {

    @TestVisible
    private Task task;
   
    public MyTaskController(Task task) { 
    	this.task = task;
    }

    //AccountId, ActivityDate, CallDisposition, Id, Status, Subject,
    //TaskSubtype,WhatId,WhoId
    public MyTaskController() {
        task = [SELECT Id, Subject, Type, TaskSubtype, Status, WhatId, 
                	   WhoId, AccountId, ActivityDate, CallDisposition, Recording_Link__c  FROM Task 
                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }

    public Task getTask() {
        return task;
    }

}