trigger ContentDocumentLinkTriggerAction on ContentDocumentLink (after delete, after insert) {
    
    
    if(trigger.isAfter && trigger.isInsert && !System.isBatch() && !System.isFuture()  ){
    	list<ContentDocumentLink> ContentDocumentLinklist = new list<ContentDocumentLink>();
    	
    	for( ContentDocumentLink documentlink : trigger.new ){
    		if(documentlink.LinkedEntityId != null 
    			&&  ( String.valueOf(documentlink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('Lead')
    				|| String.valueOf(documentlink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('Opportunity')
    				|| String.valueOf(documentlink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('Quote')
    				|| String.valueOf(documentlink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('Expense__c')) ){
    			
    			ContentDocumentLinklist.add( documentlink ); 
    		}
    	} 
    	if( ContentDocumentLinklist != null && !ContentDocumentLinklist.isEMpty() ){
    		Database.executeBatch( new BatchToHandleFileInGDrive( ContentDocumentLinklist ), 1);
    	}
    }
}