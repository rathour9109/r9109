public with sharing class accountFilteredList {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccList(){
        try {
            return [SELECT Id, Name, Type__c, Debit__c, Credit__c, Transaction__c, Rolling_Balance__c FROM Account WHERE Type__c!=null ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}