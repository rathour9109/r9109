trigger OpportunityTaskTrigger on Opportunity (after insert, after update) {
    if (trigger.isAfter) {
        if(trigger.isInsert) {
            OpportunityTaskHandler.relatedTask(Trigger.new, null);
        }
        else if (trigger.isUpdate) {
            OpportunityTaskHandler.relatedTask(Trigger.new, Trigger.oldMap);
        }
    }
}