/*------------------------------------------------------------------------------------------------------------------------ *
Author		: Salesforce Services
Company     : Salesforce
Description : Generic Trigger Framework, adapted from the SFDC Trigger Framework by Kevin o'Hara.
              It provides a proven lightweight trigger framework implementation with a bypass feature
              using the GlobalBypassProcessesSettings__c custom setting. Triggers can be bypassed all together
              or bypassed individually. The GlobalBypassProcessesSettings__c setting is hierarchical such
              that on a per-user basis triggers can be disabled. A comfortable feature while executing data migration, data fixes etc.
              For implementation, please refer to Kevin's repository.
Source      : https://github.com/kevinohara80/sfdc-trigger-framework
Inputs      : None
Test Class  : Test_TriggerHandler
History     : Adapted in 2018, forked from the original source.
              Enable a global bypass by means of a custom setting (GlobalBypassProcessesSettings__c)
------------------------------------------------------------------------------------------------------------------------*/
public virtual class TriggerHandler
{
    // static map of handler name, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;

    private final static String COMMA_SEPARATOR = ',';

    // static initialization
    static
    {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
    }

    // constructor
    public TriggerHandler()
    {
        this.setTriggerContext();
    }

    /***************************************
     * public instance methods
     ***************************************/

    // main method that will be called during execution
    public void run()
    {
        if (!validateRun()) return;

        addToLoopCount();

        // dispatch to the correct handler method
        if (this.context == TriggerContext.BEFORE_INSERT)
        {
            this.beforeInsert();
        }
        else if (this.context == TriggerContext.BEFORE_UPDATE)
        {
            this.beforeUpdate();
        }
        else if (this.context == TriggerContext.BEFORE_DELETE)
        {
            this.beforeDelete();
        }
        else if (this.context == TriggerContext.AFTER_INSERT)
        {
            this.afterInsert();
        }
        else if (this.context == TriggerContext.AFTER_UPDATE)
        {
            this.afterUpdate();
        }
        else if (this.context == TriggerContext.AFTER_DELETE)
        {
            this.afterDelete();
        }
        else if (this.context == TriggerContext.AFTER_UNDELETE)
        {
            this.afterUndelete();
        }

    }

    public void setMaxLoopCount(Integer max)
    {
        String handlerName = getHandlerName();
        if (!TriggerHandler.loopCountMap.containsKey(handlerName))
        {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        }
        else
        {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    public void clearMaxLoopCount()
    {
        this.setMaxLoopCount(-1);
    }

    /***************************************
     * public static methods
     ***************************************/

    public static void bypass(String handlerName)
    {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }

    public static void clearBypass(String handlerName)
    {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    public static Boolean isBypassed(String handlerName)
    {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    public static void clearAllBypasses()
    {
        TriggerHandler.bypassedHandlers.clear();
    }

    /***************************************
     * private instancemethods
     ***************************************/

    @TestVisible
    private void setTriggerContext()
    {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode)
    {
        if (!Trigger.isExecuting && !testMode)
        {
            this.isTriggerExecuting = false;
            return;
        }
        else
        {
            this.isTriggerExecuting = true;
        }

        if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
                (ctx != null && ctx == 'before insert'))
        {
            this.context = TriggerContext.BEFORE_INSERT;
        }
        else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                (ctx != null && ctx == 'before update'))
        {
            this.context = TriggerContext.BEFORE_UPDATE;
        }
        else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                (ctx != null && ctx == 'before delete'))
        {
            this.context = TriggerContext.BEFORE_DELETE;
        }
        else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                (ctx != null && ctx == 'after insert'))
        {
            this.context = TriggerContext.AFTER_INSERT;
        }
        else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                (ctx != null && ctx == 'after update'))
        {
            this.context = TriggerContext.AFTER_UPDATE;
        }
        else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                (ctx != null && ctx == 'after delete'))
        {
            this.context = TriggerContext.AFTER_DELETE;
        }
        else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                (ctx != null && ctx == 'after undelete'))
        {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    // increment the loop count
    @TestVisible
    private void addToLoopCount()
    {
        String handlerName = getHandlerName();
        if (TriggerHandler.loopCountMap.containsKey(handlerName))
        {
            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
            if (exceeded)
            {
                Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }

    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun()
    {
        Boolean triggerCanRun = true;
        if (!this.isTriggerExecuting || this.context == null)
        {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }
        else if (TriggerHandler.bypassedHandlers.contains(getHandlerName()))
        {
            triggerCanRun = false;
        }
        else if(GlobalBypassProcessesSettings__c.getInstance() != null)
        {
            if(!GlobalBypassProcessesSettings__c.getInstance().RunTriggers__c)
            {
                triggerCanRun = false;
            }
            else if(String.isNotBlank(GlobalBypassProcessesSettings__c.getInstance().TriggerObjectsBypass__c))
            {
                Set<String> objectsTypeToByPassList =  new Set<String>(GlobalBypassProcessesSettings__c.getInstance().TriggerObjectsBypass__c.split(COMMA_SEPARATOR));
                List<SObject> triggerOldList = Trigger.old != null ? Trigger.old : new List<SObject>();
                List<SObject> triggerNewList = Trigger.new != null ? Trigger.new : new List<SObject>();
                String currentSObjectType = !triggerOldList.isEmpty() ? triggerOldList[0].getSObjectType().getDescribe().getName() : (!triggerNewList.isEmpty() ? triggerNewList[0].getSObjectType().getDescribe().getName() : null);
                if(objectsTypeToByPassList.contains(currentSObjectType))
                {
                    triggerCanRun = false;
                }
            }
        }
        return triggerCanRun;
    }

    @TestVisible
    private String getHandlerName()
    {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }

    /***************************************
     * context methods
     ***************************************/

    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert()
    {
    }
    @TestVisible
    protected virtual void beforeUpdate()
    {
    }
    @TestVisible
    protected virtual void beforeDelete()
    {
    }
    @TestVisible
    protected virtual void afterInsert()
    {
    }
    @TestVisible
    protected virtual void afterUpdate()
    {
    }
    @TestVisible
    protected virtual void afterDelete()
    {
    }
    @TestVisible
    protected virtual void afterUndelete()
    {
    }

    /***************************************
     * inner classes
     ***************************************/

    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount
    {
        private Integer max;
        private Integer count;

        public LoopCount()
        {
            this.max = 5;
            this.count = 0;
        }

        public LoopCount(Integer max)
        {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment()
        {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded()
        {
            if (this.max < 0) return false;
            if (this.count > this.max)
            {
                return true;
            }
            return false;
        }

        public Integer getMax()
        {
            return this.max;
        }

        public Integer getCount()
        {
            return this.count;
        }

        public void setMax(Integer max)
        {
            this.max = max;
        }
    }

    // possible trigger contexts
    @TestVisible
    private enum TriggerContext
    {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }

    // exception class
    public class TriggerHandlerException extends Exception
    {
    }

}