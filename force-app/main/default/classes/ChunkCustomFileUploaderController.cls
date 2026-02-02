public with sharing class ChunkCustomFileUploaderController {

    private static Map<String, List<String>> chunkStore = new Map<String, List<String>>();

    @AuraEnabled
    public static void uploadChunk(
        String uploadId,
        String fileName,
        String chunkData,
        Integer chunkIndex,
        Boolean isLastChunk,
        Id recordId
    ) {
        if (!chunkStore.containsKey(uploadId)) {
            chunkStore.put(uploadId, new List<String>());
        }

        List<String> chunks = chunkStore.get(uploadId);

        if (chunks.size() <= chunkIndex) {
            chunks.add(chunkData);
        } else {
            chunks[chunkIndex] = chunkData;
        }

        if (isLastChunk) {
            String fullBase64 = String.join(chunks, '');
            Blob fileBlob = EncodingUtil.base64Decode(fullBase64);

            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName;
            cv.VersionData = fileBlob;
            insert cv;

            Id contentDocId = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id = :cv.Id
            ].ContentDocumentId;

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentDocId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;

            chunkStore.remove(uploadId);
        }
    }

    @AuraEnabled
    public static void cancelUpload(String uploadId) {
        chunkStore.remove(uploadId);
    }
}