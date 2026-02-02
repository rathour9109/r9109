public with sharing class BatchToHandleFileInGDrive implements Database.Batchable<ContentDocumentLink>, Database.allowscallouts {
    
    public list<ContentDocumentLink> ContentDocumentLinklist;
    public BatchToHandleFileInGDrive(  list<ContentDocumentLink> ContentDocumentLinklist ){
    	this.ContentDocumentLinklist = ContentDocumentLinklist;
    }
    
    public Iterable<ContentDocumentLink> start(Database.BatchableContext BC){
    	return ContentDocumentLinklist;
    }
    
    public void execute(Database.BatchableContext BC, List<ContentDocumentLink> scope){
    	ContentDocumentLink conDoculink = scope[0];
    	
    	String folderId = '';
    	if( conDoculink.LinkedEntityId != null && String.valueOf(conDoculink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('Lead') ){
    			
    		list<Lead> leadList = new list<Lead>();
    		leadList = [select id, Google_Drive_Folder_Id__c from lead 
    					where Id =: conDoculink.LinkedEntityId  
    					and Google_Drive_Folder_Id__c != null and isconverted = false  limit 1 ];
    		
    		if( leadList != null && !leadList.isEmpty()){
    			folderId = leadList[0].Google_Drive_Folder_Id__c;
    		}
    	}else if( conDoculink.LinkedEntityId != null && String.valueOf(conDoculink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('Opportunity')){
    			
    		list<Opportunity> oppList  = new list<Opportunity>();
    		oppList = [select id, Google_Drive_Folder_Id__c from Opportunity 
    					where Id =: conDoculink.LinkedEntityId  
    					and Google_Drive_Folder_Id__c != null limit 1 ];
    		
    		if( oppList != null && !oppList.isEmpty()){
    			folderId = oppList[0].Google_Drive_Folder_Id__c;
    		}
    	}
    	list<lead> convertedLeadlist = new list<Lead>();
    	if(conDoculink.LinkedEntityId != null && String.valueOf(conDoculink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('Lead') ){
    			
    		convertedLeadlist = [select id from lead where convertedOpportunityId =: conDoculink.LinkedEntityId  
									and isconverted = true 
	      							and Google_Drive_Folder_Id__c != null  limit 1 ];
    	} 
    	if( convertedLeadlist == null || convertedLeadlist.isEmpty() ){
    		
    		list<ContentVersion> ContentVersionlist = new list<ContentVersion>();
	    	ContentVersionlist = [ select id, ContentDocumentId, Title, VersionData, ContentSize, FileType, IsMajorVersion 
	        						from ContentVersion where ContentDocumentId =: conDoculink.ContentDocumentId ];
	    	
	    	if( folderId != null && folderId != '' && ContentVersionlist != null && !ContentVersionlist.isEmpty() ){
	    		HttpResponse response = GoogleCalloutUtility.uploadFile( ContentVersionlist[0], folderId);
	    		
	    		if( response != null && response.getStatusCode() == 200){
		      		map<String,object> rawResponse = new map<String,object>();
		      		rawResponse = ( map<String,object> )JSon.deserializeUntyped( response.getBody() );
			    } 
	    	}
    	}
    } 
    public void finish(Database.BatchableContext BC){  
    }
}