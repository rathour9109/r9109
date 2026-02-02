public with sharing class ExternalAPIClient {
    
    private static final String BASE_URL = 'http://universities.hipolabs.com/search?country=India'; 
    //private static final String API_KEY = 'your-api-key';
    
    /**
     * Send a GET request to an external API.
     * @param endpoint The API endpoint to call (e.g., "/users")
     * @return API response as a JSON string
     */
    public static String sendGetRequest(String endpoint) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BASE_URL + endpoint);
            request.setMethod('GET');
            //request.setHeader('Authorization', 'Bearer ' + API_KEY);
            request.setHeader('Authorization', 'Bearer ');
            request.setHeader('Content-Type', 'application/json');

            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return response.getBody();
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getBody());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
    }

    /**
     * Send a POST request to an external API.
     * @param endpoint The API endpoint to call (e.g., "/createUser")
     * @param jsonBody The JSON payload to send
     * @return API response as a JSON string
     */
    public static String sendPostRequest(String endpoint, String jsonBody) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BASE_URL + endpoint);
            request.setMethod('POST');
            //request.setHeader('Authorization', 'Bearer ' + API_KEY);
            request.setHeader('Authorization', 'Bearer ');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(jsonBody);

            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 201 || response.getStatusCode() == 200) {
                return response.getBody();
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' - ' + response.getBody());
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
    }
}