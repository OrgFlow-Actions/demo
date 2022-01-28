public with sharing class flowLookupLwcController {

    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds, String accountId, List<String> searchObjects) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query

        List<List<SObject>> searchResults = new List<List<SObject>>();
        
        /*if(searchObjects.contains('Account')){
            searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Account(Id, Name, BillingCity WHERE id NOT IN :selectedIds)
                LIMIT :MAX_RESULTS
            ];
        }*/

        Set<Id> contactIdSet = new Set<Id>();
        for (AccountContactRelation accConRelation : [SELECT Id, ContactId FROM AccountContactRelation WHERE AccountId = :accountId]) {
            contactIdSet.add(accConRelation.ContactId);
        }

        if(searchObjects.contains('Contact')){
            searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Contact(Id, Name, FirstName, LastName, Email, Phone WHERE id NOT IN :selectedIds AND Id IN :contactIdSet)
                LIMIT :MAX_RESULTS
            ];
        }


        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult

        /*if(searchObjects.contains('Account')){
            String accountIcon = 'standard:account';
            Account[] accounts = (List<Account>) searchResults[0];
            for (Account account : accounts) {
                String subtitle = account.BillingCity == null ? 'Account' : 'Account • ' + account.BillingCity;
                results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, subtitle));
            }
        }*/
        
        // Extract Contacts & convert them into LookupSearchResult
        if(searchObjects.contains('Contact')){
            String contactIcon = 'standard:contact';
            Contact[] contacts = (List<Contact>) searchResults[0];
            for (Contact contact : contacts) {
                results.add(new LookupSearchResult(contact.Id, 'Contact', contactIcon, contact.Name, 'Contact • ' + contact.Name));
            }
        }
        // Optionnaly sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getRecentlyViewed(String accountId, String recordId) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        /*List<RecentlyViewed> recentRecords = [
            SELECT Id, Name, Type
            FROM RecentlyViewed
            WHERE Type = 'Account' OR Type = 'Opportunity'
            ORDER BY LastViewedDate DESC
            LIMIT 5
        ];*/

        List<Contact> recentRecords = new List<Contact>();

        if(recordId.left(3) == '003'){
            recentRecords = [
                SELECT Id, Name, FirstName, LastName
                FROM Contact
                WHERE Id =: recordId
            ];
        }
        else if(accountId != null){
            recentRecords = [
                SELECT Id, Name, FirstName, LastName
                FROM Contact
                WHERE AccountId =: accountId
            ];
        }
        // Convert recent records into LookupSearchResult
        for (Contact recentRecord : recentRecords) {

                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'Contact',
                        'standard:contact',
                        recentRecord.Name,
                        'Contact • ' + recentRecord.Name
                    )
                );
            
        }
        return results;
    }



}