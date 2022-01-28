trigger SalesHistorySetPayerLookup on Sales_History__c (before insert, before update)
{
    	// Collect a list of all Payer_Movex_D_JP__c values of the affected records.
	List<String> payerMovexNumberList = new List<String>();
	for (Object o : al.ArrayUtils.pluck(trigger.new, 'Payer_Movex_D_JP__c'))
		if (o != null)
			payerMovexNumberList.add((String)o);
	
	// Download the Id and Movex__c values for related payer Accounts.
	List<Account> accounts = [SELECT Id, Movex__c FROM Account WHERE Movex__c IN :payerMovexNumberList];
	
	// Construct a map of Movex__c to Id.
	Map<String, ID> accountMap = new Map<String, ID>();
	for (Account a : accounts)
		accountMap.put(a.Movex__c, a.Id);	
	
	// Set the Id value of the related payer Account in the
	// Payer_Lookup__c field of each affected record.
	for (Sales_History__c s : trigger.new)
	{
		if (s.Payer_Movex_D_JP__c != null)
		{
			if (accountMap.containsKey(s.Payer_Movex_D_JP__c))
			{
				ID payerLookupId = accountMap.get(s.Payer_Movex_D_JP__c);
                s.Payer_Lookup__c = payerLookupId;
                continue;
			}
		}
        
        s.Payer_Lookup__c = null;
	}
}