trigger subscribePlatformEventTrigger on Order_Detail__e (after insert) {
    if((Trigger.isAfter && Trigger.isInsert)){
        subscribePlatformEvent.afterInsert(Trigger.new);
    }
}