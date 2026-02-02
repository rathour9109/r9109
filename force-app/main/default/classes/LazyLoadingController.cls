/**
* @File Name : LazyLoadingController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : October 27, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 27, 2025 |   | Initial Version
**/

public with sharing class LazyLoadingController {

    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(Integer limitSize, Integer offset){
        List<Account> accountList = [SELECT Id,Name,Rating
                                     FROM Account
                                     ORDER BY CreatedDate
                                     LIMIT :limitSize
                                     OFFSET :offset
                                     ];
        return accountList;
    }
}