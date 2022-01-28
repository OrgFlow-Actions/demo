@IsTest
public with sharing class Test_EinsteinOCR {

    @IsTest
    private static void Test_EinsteinOCR() {

        EinsteinOCRService.AuraResponseWrapper response1 = EinsteinOCRService.readBusinessCardBase64('','Contact','');
        System.debug(response1);
        EinsteinOCRService.AuraResponseWrapper response2 = EinsteinOCRService.readBusinessCardBase64('','Contact',null);
        System.debug(response2);

        EinsteinOCRService.readBusinessCard();
        EinsteinOCRService.readTextFromImageByURL();
    }

    @IsTest
    private static void Test_logTask(){
        String testRes = EinsteinOCRService.logActivity(null, null);
        System.debug(testRes);
    }
}