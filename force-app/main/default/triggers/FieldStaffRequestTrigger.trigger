trigger FieldStaffRequestTrigger on Field_Staff_Request__c (before insert, before update) {

    System.debug('FieldStaffRequestTrigger ----- START ----');
    System.debug('Trigger Operation: ' + Trigger.operationType);

    Boolean isInsert = Trigger.isInsert;
    Boolean isUpdate = Trigger.isUpdate;

    System.debug('LINE9>>>>'+ 'isInsert: ' + isInsert + ', isUpdate: ' + isUpdate);

    if (isInsert || isUpdate) {
        System.debug('Trigger.new: ' + Trigger.new);
        System.debug('Trigger.oldMap: ' + Trigger.oldMap);

        FieldStaffRequestHandler.validateLimit(Trigger.new);
    }

    System.debug('FieldStaffRequestTrigger ----- END ----');
}