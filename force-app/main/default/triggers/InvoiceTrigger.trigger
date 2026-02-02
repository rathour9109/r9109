trigger InvoiceTrigger on Invoice (after insert , after update , after delete , after undelete) {
	InvoiceTriggerHandler.invoiceMethod(trigger.new, trigger.oldmap);
}