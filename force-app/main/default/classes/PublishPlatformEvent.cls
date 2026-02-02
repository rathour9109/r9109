public with sharing class PublishPlatformEvent {
    public static void PublishPlatformEventDemo() {
        List<Order_Detail__e> orderDetailListEvent = new List<Order_Detail__e>();
        orderDetailListEvent.add(new Order_Detail__e(
            Order_Number__c = 'ORD2000',
            Generate_Invoice__c = false)
        );
        orderDetailListEvent.add(new Order_Detail__e(
            Order_Number__c = 'ORD3000',
            Generate_Invoice__c = true)
        );
        orderDetailListEvent.add(new Order_Detail__e(
            Order_Number__c = 'ORD4000',
            Generate_Invoice__c = false)
        );
        PublishPlatformEventCallback callbackInstance = new PublishPlatformEventCallback(); 
        List<Database.SaveResult> srList = EventBus.publish(
            orderDetailListEvent,
            callbackInstance);

        for (Database.SaveResult srItem : srList) {
            if (srItem.isSuccess()) {
                    System.debug('Platform Event published Successfully.');
            } else {
                List<Database.error> errList = srItem.getErrors();
                for(Database.Error errorDetail : errList) {
                    System.debug('Error Details: ' + errorDetail.getMessage());
                }
            }
        }
    }
}