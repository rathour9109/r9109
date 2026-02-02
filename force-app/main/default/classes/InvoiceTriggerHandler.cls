public class InvoiceTriggerHandler {
	public static void invoiceMethod(List<Invoice> newInvoices, Map<Id,Invoice> oldInvoicesMap){
        Set<Id>accIds = new Set<Id>();
        
        if(!newInvoices.isEmpty()){
            for(Invoice inv : newInvoices){
                if(inv.Account__c!= null){
                    accIds.add(inv.Account__c);  
                }
            }
        }
        if(oldInvoicesMap != null && !oldInvoicesMap.isEmpty()){
            for(Invoice inv : oldInvoicesMap.values()){
                if(inv.Account__c!=null){
                    accIds.add(inv.Account__c);
                }
            }
        }
        
        List<AggregateResult> aggrList = [Select Account__c acc , MAX(Overdue_Days__c)Maxdays FROM Invoice WHERE Account__c 
                                          IN : accIds GROUP BY Account__c];

        Map<Id,Decimal> invMap = new Map <Id,Decimal>();

        for(AggregateResult aggr : aggrList){
            Id accId = (Id)aggr.get('acc');
            Decimal Maxdays = (Decimal)aggr.get('Maxdays');
            invMap.put(accId,Maxdays);
        }

        List<Account> accList = [SELECT Highest_Overdue_Days__c, Credit_Risk_Level__c FROM Account WHERE Id IN : accIds];

        List<Account> newAccList = new List <Account>();
        for(Account acc : accList){
            Decimal Maxdays = 0;
            if(invMap.containsKey(acc.Id)){
                Maxdays = invMap.get(acc.Id);
            }
            acc.Highest_Overdue_Days__c = Maxdays;
            
            if(acc.Highest_Overdue_Days__c>=90){
                acc.Credit_Risk_Level__c = 'High Risk';
            }
            if(acc.Highest_Overdue_Days__c >= 45 && acc.Highest_Overdue_Days__c <= 89){
                acc.Credit_Risk_Level__c = 'Medium Risk';
            }
            if(acc.Highest_Overdue_Days__c < 45){
                acc.Credit_Risk_Level__c = 'Low Risk';
            }
            newAccList.add(acc);
        }
        if(!newAccList.isEmpty()){
            update newAccList;
        }
    }
}