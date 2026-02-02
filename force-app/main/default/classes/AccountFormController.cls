public with sharing class AccountFormController {

    @AuraEnabled(cacheable=true)
    public static List<Account> searchAccounts(String searchKey) {
        String key = '%' + searchKey + '%';
        return [
            SELECT Id, Name, Rating, Phone, SLA__c
            FROM   Account
            WHERE  Name LIKE :key
            ORDER  BY Name
            LIMIT  20
        ];
    }

    @AuraEnabled
    public static Id createAccount(Map<String, Object> fields) {
        Account acc = new Account();
        if (fields.containsKey('Name'))   acc.Name   = (String)fields.get('Name');
        if (fields.containsKey('Rating')) acc.Rating = (String)fields.get('Rating');
        if (fields.containsKey('Phone'))  acc.Phone  = (String)fields.get('Phone');
        if (fields.containsKey('SLA__c')) acc.SLA__c = (String)fields.get('SLA__c');
        insert acc;
        return acc.Id;
    }
    
    @AuraEnabled
    public static void updateAccount(Map<String, Object> fields) {
        Account acc = new Account(
            Id      = (Id)     fields.get('Id'),
            Name    = (String) fields.get('Name'),
            Rating  = (String) fields.get('Rating'),
            Phone   = (String) fields.get('Phone'),
            SLA__c  = (String) fields.get('SLA__c')
        );
        update acc;
    }

    @AuraEnabled
    public static void deleteAccount(Id accId) {
        delete [SELECT Id FROM Account WHERE Id = :accId];
    }
}