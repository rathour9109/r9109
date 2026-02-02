@isTest
public with sharing class PublishPlatformEventCallbackTest {
    @isTest
    static void testFailedEvents() {
        Order_Detail__e orderDetail = new Order_Detail__e(
            Order_Number__c = 'ORD4000',
            Generate_Invoice__c = false
        );
        publishPlatformEventCallback cb = new publishPlatformEventCallback();
        EventBus.publish(orderDetail, cb);
        Test.getEventBus().fail();
        List<Task> taskList = [SELECT Id, Subject, Description FROM Task WHERE Subject ='Platform Event Publish Failed'];
        System.Assert.areEqual(1, taskList.size(),'Task Creation Failed');
    }
    static void testSuccessEvents() {
        Order_Detail__e orderDetail = new Order_Detail__e(
            Order_Number__c = 'ORD4000',
            Generate_Invoice__c = false
        );
        publishPlatformEventCallback cb = new publishPlatformEventCallback();
        EventBus.publish(orderDetail, cb);
        Test.startTest();
        EventBus.publish(orderDetail, cb);
        Test.stopTest();
        List<Task> taskList = [SELECT Id, Subject, Description FROM Task WHERE Subject ='Platform Event Published Successfully'];
        System.Assert.areEqual(1, taskList.size(),'Task Created Failed');
    }
}