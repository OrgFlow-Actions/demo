/*------------------------------------------------------------
Author:         Kevin Do (Salesforce) 2019-09-25
Description:    Account Trigger Handler Class.
History
<Date>      <Authors Name>     <Brief Description of Change>
20190924    Kevin Do            Migrated DC_AccountTrigger and AccountSetPayerLookup triggers. (#TFUS1030)
20200326    Kevin Do            Added call to setAccountSubSegmentation in beforeInsert and beforeUpdate (#TFUS-000001698)
20200817    Richard Trum        Added afterUpdate section, calling the new updateRelatedContactAddresses method (#TFUS2084)
20210405    Nisreen Al-Saleh    Added afterInsert, calling the createEntitlement method (#TFUS-000001231)
------------------------------------------------------------*/

public class AccountTriggerHandler extends TriggerHandler {
    private List<Account> oldAccountList, newAccountList;
    private Map<Id, Account> oldAccountMap, newAccountMap;

    public AccountTriggerHandler() {
        oldAccountList = (List<Account>) Trigger.old;
        newAccountList = (List<Account>) Trigger.new;
        oldAccountMap = (Map<Id, Account>) Trigger.oldMap;
        newAccountMap = (Map<Id, Account>) Trigger.newMap;
    }

    protected override void beforeInsert() {
        Integer t0 = Limits.getCpuTime();
        System.debug('cpu b ' + Limits.getCpuTime() + ' ' + Limits.getLimitCpuTime());
        AccountTriggerHelper.setPostalCodeInfoAndEtmCode(newAccountList, oldAccountMap);
        System.debug('cpu b2 ' + Limits.getCpuTime() + ' ' + Limits.getLimitCpuTime());
        AccountTriggerHelper.setPayerLookup(newAccountList, oldAccountMap);
        // WorkFlows
        for(Account account : newAccountList) {
            AccountTriggerHelper.overridePotential(account);
            System.debug('cpu a1 ' + Limits.getCpuTime() + ' ' + Limits.getLimitCpuTime());
            AccountTriggerHelper.dentalProspectMovex(account);
        }
        System.debug('cpu a2 ' + Limits.getCpuTime() + ' ' + Limits.getLimitCpuTime());
        AccountTriggerHelper.updateRecordsType(newAccountList);
        System.debug('cpu a3 ' + Limits.getCpuTime() + ' ' + Limits.getLimitCpuTime());
        AccountTriggerHelper.updateVolume(newAccountList);
        System.debug('cpu a4 ' + Limits.getCpuTime() + ' ' + Limits.getLimitCpuTime());
        AccountTriggerHelper.updateAccountsInfo(newAccountList);
        System.debug('cpu a5 ' + Limits.getCpuTime() + ' ' + Limits.getLimitCpuTime());
        AccountTriggerHelper.setAccountDefaultOwnerOnCreate(newAccountList);
        System.debug('cpu a6 ' + Limits.getCpuTime() + ' ' + Limits.getLimitCpuTime());
        AccountTriggerHelper.setAccountDefaultOwner(newAccountList, oldAccountMap);
        System.debug('cpu a7 ' + Limits.getCpuTime() + ' ' + Limits.getLimitCpuTime());
        //AccountTriggerHelper.updateAccountsStrategyIcon(newAccountList);
        AccountTriggerHelper.setAccountSubSegmentation(newAccountList, oldAccountMap);
        System.debug('cpu a ' + (Limits.getCpuTime()  - t0)); // Almost 1583 MS with ALL WF
    }

    protected override void beforeUpdate() {
        AccountTriggerHelper.setPostalCodeInfoAndEtmCode(newAccountList, oldAccountMap);
        AccountTriggerHelper.setPayerLookup(newAccountList, oldAccountMap);
        // WorkFlows
        for(Account account : newAccountList) {
            AccountTriggerHelper.overridePotential(account);
            AccountTriggerHelper.dentalProspectMovex(account);
        }
        AccountTriggerHelper.updateRecordsType(newAccountList);
        AccountTriggerHelper.updateVolume(newAccountList);
        AccountTriggerHelper.updateAccountsInfo(newAccountList);
        AccountTriggerHelper.setAccountDefaultOwner(newAccountList, oldAccountMap);
        AccountTriggerHelper.updateAccountsStrategyIcon(newAccountList);
        AccountTriggerHelper.setAccountSubSegmentation(newAccountList, oldAccountMap);  
    }

    protected override void afterUpdate(){
        AccountTriggerHelper.updateRelatedContactAddresses(newAccountList, oldAccountMap, newAccountMap);
      AccountTriggerHelper.createEntitlement(newAccountList);
        
    }
    protected override void afterInsert() {
       AccountTriggerHelper.createEntitlement(newAccountList);
    }
}