public with sharing class NewOpportunity {
   
    @AuraEnabled
    public static void createOpportunity(Id contactId, String name, String stage, Date closeDate){
        insert new Opportunity(
            Name = name,
            StageName = stage,
            CloseDate = closeDate,
            ContactId = contactId,
            Contact__c = contactId
        );
    }
}