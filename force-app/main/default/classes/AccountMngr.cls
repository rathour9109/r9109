@RestResource(urlMapping='/Account/*')
global with sharing class AccountMngr {
    
    @HttpDelete
    global static void doDelete(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Account account = [SELECT Id FROM Account WHERE Id =: accountId];
        delete account;
    }

    @HttpGet
    global static Account doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        if(String.isEmpty(accountId) || accountId.length() !=15 && accountId.length() !=18){
            res.statusCode = 400;
            res.responseBody = Blob.valueof('Invalid');
            return null;
            
        }
        List<Account> result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id=: accountId limit 1];
   //     return result;
        
        if(result == null){
            res.statusCode = 404;
            res.responseBody = Blob.valueof('Account not found');
            return null;
        }
        Account account = result[0];
        return account;
    }
    
    @HttpPost
    global static String doPost(String name,String phone, String website){
        Account account = new Account();
        account.Name = name;
        account.phone = phone;
        account.website = website;
        insert account;
        return account.Id;
    }
}