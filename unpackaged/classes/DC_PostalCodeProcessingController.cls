public class DC_PostalCodeProcessingController {
    
    public Id batchJobId {get; set;}
    public String batchStatus {get; set;}
    public List<AsyncApexJob> finishedJobs {get; set;}
    public String finishedJobsStr {get; set;}
    public Boolean runningJobExist {get; set;}
    private Id batchClassId {get; set;}
    
    private final String CLASSNAME = '%DC_PostalCodeProcessingBatch%';
    

    public DC_PostalCodeProcessingController() {
        try {
            this.batchClassId = [Select Id FROM ApexClass WHERE Name Like :CLASSNAME LIMIT 1].Id;
            init();
        } catch(Exception e) {}
    }
    
    private void init() {
        runningJobExist = false;
        try {
            batchJobId = getWorksBatchJobIdByClassId(batchClassId);
            setFinishedBatchJobs();
            jobToString();
            runningJobExist = true;
        } catch(Exception e) {
        	setFinishedBatchJobs();
            jobToString();
        }
    }
    
    public void startJob() {
        try {
            batchJobId = Database.executeBatch(new DC_PostalCodeProcessingBatch());
            runningJobExist = true;
            checkJob();
        }
        catch(Exception e){runningJobExist = false;}
    }
    
    private void setFinishedBatchJobs() {
        this.finishedJobs = [Select Id, CompletedDate, ExtendedStatus, NumberOfErrors, TotalJobItems, Status
                  FROM AsyncApexJob WHERE ApexClassID = :batchClassId AND 
                       (Status = 'Failed' OR Status = 'Aborted' OR Status = 'Completed') 
                       ORDER BY CompletedDate DESC LIMIT 5];
    }
    
    public void jobToString() {
        Set<String> results = new Set<String>();  
        for(AsyncApexJob job : finishedJobs) {
            results.add('Job Status: ' + job.Status + ', Completed Date: ' + job.CompletedDate 
                + ', Total Batches: ' + job.TotalJobItems + ', Failed Batches: ' + job.NumberOfErrors);
        }
        
        finishedJobsStr = String.join(new List<String>(results), '<br/>');
    }
    
    public void checkJob() {    
        if(runningJobExist) {
            batchStatus =  [Select Status FROM AsyncApexJob WHERE ID = :batchJobId LIMIT 1].Status;
            
            if(batchStatus == 'Aborted' || batchStatus == 'Completed' || batchStatus == 'Failed') {
                init();           
            }
        }        
    }
    
    private Id getWorksBatchJobIdByClassId(Id classId) {
        return [Select Id FROM AsyncApexJob WHERE ApexClassID = :classId AND JobType = 'BatchApex' 
                                  AND (Status != 'Aborted' AND Status != 'Completed' AND Status != 'Failed') LIMIT 1].Id;
    }
}