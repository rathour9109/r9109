public with sharing class CaseApprovalHelper {

    @InvocableMethod(label='Check In Approval Timeout')
    public static void checkInApprovalTimeout(List<Id> caseIds) {

        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'India Hours' LIMIT 1];
		System.debug('line7>>>>>'+ bh);
       	
        Map<Id, DateTime> inApprovalStartMap = new Map<Id, DateTime>();

        for (CaseHistory ch : [
            SELECT CaseId, OldValue, NewValue, CreatedDate
            FROM CaseHistory
            WHERE CaseId IN :caseIds
              AND Field = 'Status'
            ORDER BY CreatedDate ASC
        ]) {
            if(String.valueOf(ch.NewValue) == 'Working') {
                inApprovalStartMap.put(ch.CaseId, ch.CreatedDate);
            }
        }
		System.debug('line22>>>>>'+ inApprovalStartMap);
        
        List<Case> casesToUpdate = new List<Case>();

        for(Case c : [SELECT Id, Status, Product__c
                       FROM Case
                       WHERE Id IN :caseIds]) {

            DateTime startTime = inApprovalStartMap.get(c.Id);
			System.debug('line31>>>>>'+ startTime);
            System.debug('line32>>>>>'+ System.now());
            if(startTime != null && c.Status == 'Working') {

                Long ms = BusinessHours.diff(bh.Id, startTime, System.now());
                system.debug('LINE35>>>'+ ms);
                Decimal hoursElapsed = ms / (1000 * 60 * 60);
               
            //    Decimal minutesElapsed = ms / (1000 * 60);
            //    system.debug('minutesElapsed>>>'+ minutesElapsed);
                
				system.debug('hoursElapsed>>>'+ hoursElapsed);
          	    if(hoursElapsed >= 0.0167) {
            //      if(minutesElapsed >= 1) {
                    c.Status = 'Done';
                    c.Product__c = 'GC3020';
                    casesToUpdate.add(c);
                }
            }
        }
		System.debug('line44>>>>>'+ casesToUpdate);
        if(!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
}