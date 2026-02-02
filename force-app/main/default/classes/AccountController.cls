public with sharing class AccountController {
    
    @AuraEnabled
    public static void createAccList(List<Account> accList) {
    try {
        
        insert accList;
    } catch (Exception e) {
        throw new AuraHandledException('Error creating accounts: ' + e.getMessage());
        }
    }
}