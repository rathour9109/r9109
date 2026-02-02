public with sharing class FileUploadController {

    @AuraEnabled
    public static void linkFiles(List<Id> documentIds, Id recordId) {
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        for (Id docId : documentIds) {
            links.add(new ContentDocumentLink(
                ContentDocumentId = docId,
                LinkedEntityId = recordId,
                ShareType = 'V',
                Visibility = 'AllUsers'
            ));
        }

        insert links;
    }

    @AuraEnabled
    public static void deleteFiles(List<Id> documentIds) {
        delete [
            SELECT Id
            FROM ContentDocument
            WHERE Id IN :documentIds
        ];
    }
}