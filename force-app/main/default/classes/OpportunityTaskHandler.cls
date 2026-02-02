public class OpportunityTaskHandler {
    
    public static Boolean hasRun = false;
    
    public static void relatedTask(List<Opportunity> newoppList, Map<Id, Opportunity> oldOpp) {
        if(hasRun) return;
        hasRun = true;
        
        Set<Id> oppIds = new Set<Id>();
        Map<Id, String> oppStageMap = new Map<Id, String>();
        if (newoppList == null ||newoppList.isEmpty()) return;
        
        for(Opportunity opp : newoppList) {
            
            if (oldOpp == null || opp.StageName != oldOpp.get(opp.Id).StageName) {
                oppIds.add(opp.Id);
                oppStageMap.put(opp.Id, opp.StageName);
            }
        }
        if (oppIds.isEmpty()) return;


        Map<Id, Set<String>> oppTaskMap = new Map<Id, Set<String>>();
        for (Task tk : [
            SELECT WhatId, Subject
            FROM Task
            WHERE WhatId IN :oppIds
        ]) {
            if (!oppTaskMap.containsKey(tk.WhatId)) {
                oppTaskMap.put(tk.WhatId, new Set<String>());
            }
            oppTaskMap.get(tk.WhatId).add(tk.Subject);
        }

        List<Task> tasksToInsert = new List<Task>();

        for(Id oppId : oppIds) {
            String stage = oppStageMap.get(oppId);
            Set<String> existingSubjects = oppTaskMap.get(oppId);
            
            if(existingSubjects == null) existingSubjects = new Set<String>();
            
            if (stage == 'Prospecting' && !existingSubjects.contains('Follow up with prospect')) {
                tasksToInsert.add(new Task(
                    WhatId = oppId,
                    Subject = 'Follow up with prospect',
                    Status = 'Not Started',
                    Priority = 'Normal'
                ));
            }
            else if (stage == 'Proposal/Price Quote') {
                if(!existingSubjects.contains('Prepare Proposal')) {
                    tasksToInsert.add(new Task(
                    	WhatId = oppId,
                        Subject = 'Prepare Proposal',
                        Status = 'Not Started',
                        Priority = 'Normal'
                    ));
                }
                if(!existingSubjects.contains('Review Proposal with Manager')) {
                    tasksToInsert.add(new Task(
                    	WhatId = oppId,
                        Subject = 'Review Proposal with Manager',
                        Status = 'Not Started',
                        Priority = 'Normal'
                    ));
                }
            }
            else if(stage == 'Closed Won' && !existingSubjects.contains('Send Welcome Email')) {
                tasksToInsert.add(new Task(
                	WhatId = oppId,
                    Subject = 'Send Welcome Email',
                    Status = 'Not Started',
                    Priority = 'Normal'
                ));
            }
        }
        if(!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}