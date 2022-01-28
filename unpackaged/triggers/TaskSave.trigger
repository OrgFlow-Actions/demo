trigger TaskSave on Task (after update, after  insert) {
	if ( Trigger.New.size() == 1 )
	{
     	System.debug('Creating new task from trigger');
        for(Task t : Trigger.New) 
        {
            System.debug('Task: Id= ' + t.Id);
        }
        
        Task task = Trigger.New[0];
        TaskExtension taskExtension = new TaskExtension( task ); 
        taskExtension.doLogEventCallout();
    }
}