@RestResource(urlMapping='/getSlackMessage')
global without sharing class SlackMessageReceiver {
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String body = req.requestBody.toString();
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(body);
        System.debug('Payload: ' + JSON.serializePretty(payload));
        
        if (payload.containsKey('challenge')) {
            String challenge = (String) payload.get('challenge');
            res.addHeader('Content-Type', 'text/plain');
            res.responseBody = Blob.valueOf(challenge);
            res.statusCode = 200;
            return;
        }
        
        Map<String, Object> event = (Map<String, Object>) payload.get('event');
        if (event != null) {
            String type = (String) event.get('type');
            System.debug('Event Type: ' + type);
            
            if (type == 'channel_created') {
                Map<String, Object> channel = (Map<String, Object>) event.get('channel');
                String channelId = (String) channel.get('id');
                System.debug('New Channel Created: ' + channelId);
                
                joinChannel(channelId); // Call helper method to join channel
            }
            else if (Type == 'im_open') {
                List<Case> cList = [SELECT Id, CaseNumber
                                    FROM Case
                                    WHERE CaseNumber = '00001088'];
                cList[0].Description = 'Opened';
                update cList[0];
            }
            else if (type == 'message') {
                String text = (String) event.get('text');
                String user = (String) event.get('user');
                String channelId = (String) event.get('channel');
                
                System.debug('Slack Message Text: ' + text);
                System.debug('User: ' + user);
                System.debug('Channel: ' + channelId);
                
                if (String.isNotBlank(channelId)) {
                    List<Case> casesToUpdate = [
                        SELECT Id, Status, Slack_Channel_ID__c
                        FROM Case
                        WHERE Slack_Channel_ID__c = :channelId
                        LIMIT 1
                    ];
                    
                    if (!casesToUpdate.isEmpty()) {
                        Case c = casesToUpdate[0];
                        c.Status = 'In Progress';
                        update c;
                        System.debug('Updated Case ID: ' + c.Id + ' to Status: In Progress');
                    } else {
                        System.debug('No Case found with Slack_Channel_ID__c = ' + channelId);
                    }
                }
            }
        } else {
            System.debug('No event object found in the payload.');
        }
        
        res.statusCode = 200;
    }
    public static void joinChannel(String channelId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Slack_Credential/conversations.join');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('channel', channelId);
        req.setBody(JSON.serialize(payload));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            System.debug('Joined channel: ' + channelId);
        } else {
            System.debug('Failed to join channel: ' + res.getBody());
        }
    }

    @HttpGet
    global static void verifyWebhook() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Get the challenge parameter from Slack
            String challenge = req.params.get('challenge');
            
            // Slack URL verification - return the challenge
            if (String.isNotBlank(challenge)) {
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(challenge);
                System.debug('Slack webhook verified with challenge: ' + challenge);
                return;
            }
            
            // If no challenge, return verification status
            Map<String, Object> response = new Map<String, Object>{
                'status' => 'verified',
                    'message' => 'Slack webhook endpoint is active',
                    'timestamp' => System.now().format('yyyy-MM-dd HH:mm:ss'),
                    'endpoint' => req.requestURI
                    };
                        
                        res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
        } catch (Exception e) {
            // Error response
            Map<String, Object> errorResponse = new Map<String, Object>{
                'status' => 'error',
                    'message' => 'Webhook verification failed',
                    'error' => e.getMessage()
                    };
                        
                        res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
            System.debug('Webhook verification error: ' + e.getMessage());
        }
    }
}