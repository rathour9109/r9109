trigger CaseTrigger on Case (after insert, after update) {
    if (Trigger.isAfter ) {
        
        if(Trigger.isInsert){
            caseHandler.handleUpdate (Trigger.new,null);
            
        }
        else if (Trigger.isUpdate){
            caseHandler.handleUpdate (Trigger.new,Trigger.oldMap);
            
            
        }
    }
    
    
}