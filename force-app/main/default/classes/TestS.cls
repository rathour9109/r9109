public class TestS{

    public class SlackRequestWrapper {
        @InvocableVariable(required=true)
        public String request;
    }

    @InvocableMethod
    public static void newMethod(List<SlackRequestWrapper> SlackRequest) {
        for (SlackRequestWrapper req : SlackRequest) {
            System.debug('Request: ' + req.request);
        }
    }
}