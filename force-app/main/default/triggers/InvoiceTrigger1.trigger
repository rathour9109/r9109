trigger InvoiceTrigger1 on Invoice__c (after insert, after update, after delete, after undelete) {

    System.debug('InvoiceTrigger1----- START ----LINE3>>>>');
    System.debug('Trigger Operation: ' + Trigger.operationType);

    Boolean isInsert = Trigger.isInsert;
    Boolean isUpdate = Trigger.isUpdate;
    Boolean isDelete = Trigger.isDelete;
    Boolean isUndelete = Trigger.isUndelete;

    System.debug('LINE11>>>>'+ 'isInsert>>>' + isInsert + 
                 ', isUpdate>>>' + isUpdate + 
                 ', isDelete>>>' + isDelete + 
                 ', isUndelete>>>' + isUndelete);

    if (isInsert || isUpdate || isUndelete) {
        System.debug('Trigger.new>>>' + Trigger.new);
        System.debug('Trigger.oldMap>>>' + Trigger.oldMap);

        InvoiceTrigger1Handler.invoiceMethod(Trigger.new, isUpdate ? Trigger.oldMap : null);
    }

    if (isDelete) {
        System.debug('Trigger.old>>>' + Trigger.old);
        
        InvoiceTrigger1Handler.invoiceMethod(Trigger.old, null);
    }
    System.debug('InvoiceTrigger1---- END ------LINE29');
}