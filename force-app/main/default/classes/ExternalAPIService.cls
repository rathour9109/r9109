@RestResource(urlMapping='/externalclient/*')
global with sharing class ExternalAPIService {

    @HttpGet
    global static String fetchData() {
        String response = ExternalAPIClient.sendGetRequest('/users');
        return response;
    }

    @HttpPost
    global static String sendData(String name, String email) {
        String jsonPayload = '{"name": "' + name + '", "email": "' + email + '"}';
        String response = ExternalAPIClient.sendPostRequest('/createUser', jsonPayload);
        return response;
    }
}