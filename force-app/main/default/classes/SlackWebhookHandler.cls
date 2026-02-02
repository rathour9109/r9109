@RestResource(urlMapping='/webhook/slack/*')
global class SlackWebhookHandler {
    
    @HttpPost
    global static void handleSlackEvent() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Parse incoming Slack event
            Map<String, Object> eventData = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            
            // Handle URL verification challenge (IMPORTANT: respond with JSON)
            if (
                eventData.containsKey('type') && 
                String.valueOf(eventData.get('type')) == 'url_verification' &&
                eventData.containsKey('challenge')
            ) {
                res.addHeader('Content-Type', 'application/json');
                String challengeStr = (String)eventData.get('challenge');
                res.responseBody = Blob.valueOf('{"challenge": "' + challengeStr + '"}');
                res.statusCode = 200;
                return;
            }
            
            // Process actual event
            if (eventData.containsKey('event')) {
                Map<String, Object> event = (Map<String, Object>) eventData.get('event');
                String eventType = (String) event.get('type');
                
                if (eventType == 'message' || eventType == 'app_mention') {
                    processMessageEvent(event);
                }
            }
            
            res.statusCode = 200;
        } catch (Exception e) {
            res.statusCode = 500;
            System.debug('Error processing Slack webhook: ' + e.getMessage());
        }
    }
    
    private static void processMessageEvent(Map<String, Object> event) {
        String messageText = (String) event.get('text');
        String channelId = (String) event.get('channel');
        String userId = (String) event.get('user');
        
        Pattern recordIdPattern = Pattern.compile('([a-zA-Z0-9]{15,18})');
        Matcher matcher = recordIdPattern.matcher(messageText);
        
        if (matcher.find()) {
            String recordId = matcher.group(1);
            updateSalesforceRecord(recordId, messageText, userId);
        }
    }
    
    private static void updateSalesforceRecord(String recordId, String message, String slackUserId) {
        try {
            SObject record = Database.query('SELECT Id FROM Case WHERE Id = :recordId LIMIT 1');
            
            record.put('Slack_Message__c', message);
            record.put('Last_Slack_User__c', slackUserId);
            record.put('Last_Modified_Date', System.now());
            
            update record;
        } catch (Exception e) {
            System.debug('Error updating Salesforce record: ' + e.getMessage());
        }
    }
}