public class InvoiceTrigger1Handler {

    public static void invoiceMethod(List<Invoice__c> newInvoices,Map<Id, Invoice__c> oldInvoicesMap) {

        Set<Id> accIds = new Set<Id>();

        Boolean isInsert   = Trigger.isInsert;
        Boolean isUpdate   = Trigger.isUpdate;
        Boolean isDelete   = Trigger.isDelete;
        Boolean isUndelete = Trigger.isUndelete;

        System.debug('LINE12>>>>'+ 'isInsert>>>' + isInsert + 
                     ', isUpdate>>>' + isUpdate + 
                     ', isDelete>>>' + isDelete + 
                     ', isUndelete>>>' + isUndelete);

        if ((isInsert || isUpdate || isUndelete) && newInvoices != null && !newInvoices.isEmpty()) {

            for (Invoice__c inv : newInvoices) {

                Invoice__c oldInv = (isUpdate && oldInvoicesMap != null) ? oldInvoicesMap.get(inv.Id) : null;

                if ( inv.Account__c != null &&
                    (isInsert || isUndelete || (isUpdate && oldInv != null && oldInv.Overdue_Days__c != inv.Overdue_Days__c))) 
                    {
                    accIds.add(inv.Account__c);

                    System.debug('LINE28>>>>'+ 'isInsert>>>' + isInsert + 
                                 ', isUpdate>>>' + isUpdate + 
                                 ', isDelete>>>' + isDelete + 
                                 ', isUndelete>>>' + isUndelete);
                }

                if (isUpdate && oldInv != null && oldInv.Account__c != null && oldInv.Account__c != inv.Account__c) {

                    System.debug('LINE36>>>>'+ 'isInsert>>>' + isInsert + 
                                 ', isUpdate>>>' + isUpdate + 
                                 ', isDelete>>>' + isDelete + 
                                 ', isUndelete>>>' + isUndelete);

                    accIds.add(oldInv.Account__c);
                }
            }
        }

        if (isDelete && oldInvoicesMap != null) {
            for (Invoice__c oldInv : oldInvoicesMap.values()) {
                if (oldInv.Account__c != null) {
                    accIds.add(oldInv.Account__c);
                }
            }
        }

        if (accIds.isEmpty()) return;

        /*
        List<AggregateResult> aggrList = [Select Account__c acc , MAX(Overdue_Days__c)Maxdays FROM Invoice__c WHERE Account__c 
                                          IN : accIds GROUP BY Account__c];

        Map<Id,Decimal> invMap = new Map <Id,Decimal>();

        for(AggregateResult aggr : aggrList){
            Id accId = (Id)aggr.get('acc');
            Decimal Maxdays = (Decimal)aggr.get('Maxdays');
            invMap.put(accId,Maxdays);
        }
        */

        List<Invoice__c> invoiceList = [
            SELECT Id, Account__c, Overdue_Days__c
            FROM Invoice__c
            WHERE Account__c IN :accIds
        ];

        Map<Id, Decimal> invMap = new Map<Id, Decimal>();

        for (Invoice__c inv : invoiceList) {
            if (inv.Overdue_Days__c == null) continue;

            if (!invMap.containsKey(inv.Account__c) ||
                inv.Overdue_Days__c > invMap.get(inv.Account__c)) {

                invMap.put(inv.Account__c, inv.Overdue_Days__c);
            }
        }

        /*testttttttt */

        
        List<Account> accList = [SELECT Id, Highest_Overdue_Days__c, Credit_Risk_Level__c FROM Account WHERE Id IN : accIds];

        List<Account> newAccList = new List <Account>();
        for(Account acc : accList){
            Decimal Maxdays = invMap.containsKey(acc.Id) ? invMap.get(acc.Id) : 0;
            
            acc.Highest_Overdue_Days__c = Maxdays;
            
            if (Maxdays >= 90) {
                acc.Credit_Risk_Level__c = 'High Risk';
            } else if (Maxdays >= 45) {
                acc.Credit_Risk_Level__c = 'Medium Risk';
            } else {
                acc.Credit_Risk_Level__c = 'Low Risk';
            }
            
            newAccList.add(acc);
        }
        
        if(!newAccList.isEmpty()){
            update newAccList;
        }
    }
}