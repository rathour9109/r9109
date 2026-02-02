trigger ContactTrigger on Contact (before insert) {
    
    ContactTriggerHandler.preventDuplicateContact(Trigger.new);

}