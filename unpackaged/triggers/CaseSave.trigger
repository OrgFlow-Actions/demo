trigger CaseSave on Case  (after update, after  insert) {
    if ( Trigger.New.size() == 1 )
    {
        for(Case c : Trigger.New) {
            System.debug('Case: Id= ' + c.Id );
        }
        
        Case aCase = Trigger.New[0];
        CaseExtension caseExtension = new CaseExtension( aCase ); 
        caseExtension.doLogEventCallout();
    }
}