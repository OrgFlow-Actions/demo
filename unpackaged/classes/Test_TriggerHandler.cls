/******************************************************************************************************************************************************************
 * Company: Salesforce
 * Description: Tests for TriggerHandler class
 * History :
 ******************************************************************************************************************************************************************/

@isTest
public class Test_TriggerHandler {

    @isTest
    public static void testInterface(){
        TriggerHandler trCls = new TriggerHandler();

        //Bypass methods
        TriggerHandler.bypass('HandlerTest');
        System.assertEquals(TriggerHandler.isBypassed('HandlerTest'), true);
        TriggerHandler.clearBypass('HandlerTest');
        TriggerHandler.clearAllBypasses();

        //Currently unused events
        trCls.beforeDelete();
        trCls.afterDelete();
        trCls.afterUndelete();
        trCls.afterInsert();

        //Inner class loop count handling
        TriggerHandler.LoopCount lc = new TriggerHandler.LoopCount();
        trCls.clearMaxLoopCount();
        lc.getMax();
        lc.getCount();
    }
}