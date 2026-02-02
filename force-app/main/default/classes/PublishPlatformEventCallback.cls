public with sharing class PublishPlatformEventCallback implements EventBus.EventPublishSuccessCallback, EventBus.EventPublishFailureCallback{
    
    public void onSuccess(EventBus.SuccessResult result) {
        List<String> EventUUIDList = result.getEventUuids();
        insertTask(EventUUIDList, true);
    }
    public void onFailure(EventBus.FailureResult result) {
        List<String> EventUUIDList = result.getEventUuids();
        insertTask(EventUUIDList, false);
    }

    public void insertTask(List<String> EventUUIDList, Boolean isSuccess) {
        String EventUUIDString = '';
        for(String EventUUID : EventUUIDList){
            EventUUIDString = EventUUIDString + EventUUID + '';
        }
        Task taskDetail = new Task();
        if(isSuccess == true){
            //If Platform Event Published Successfully
            taskDetail.Subject = 'Platform Event Published Successfully';
            taskDetail.Description= 'Total Platform Events Publish Success ' + 
            EventUUIDList.size() + ' List of Event UUID Published Successfully ' + 
            EventUUIDString;
        } else {
            //If Platform Event Publish Failed
            taskDetail.Subject = 'Platform Event Publish Failed ';
            taskDetail.Description = 
            'Total Platform Events Publish Failed ' + 
            EventUUIDList.size() + 
            ' List of Event UUID Published Failed ' + 
            EventUUIDString;
        }
        taskDetail.ActivityDate = Date.today();
        User userDetail = [
            SELECT Id 
            FROM User 
            WHERE Username = 'rathour9109144@agentforce.com'
            ];
        taskDetail.OwnerId = userDetail.Id;
        try{
            insert taskDetail;
        } catch (Exception e) {
            System.debug('Task Creation Failed' +e.getMessage());}
    }
}