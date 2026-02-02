public class SlackIntegration {
    private static final String SLACK_TOKEN = 'https://hooks.slack.com/services/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';
    @future(callout=true)
    public static void sendMessage(String channel, String message) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(SLACK_TOKEN);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('text', message);
        String jsonPayload = JSON.serialize(payload);
        request.setBody(jsonPayload);
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() != 200) {
            System.debug('Error sending message to Slack: ' + response.getBody());
        }
    }
}