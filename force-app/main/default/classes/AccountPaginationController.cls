public with sharing class AccountPaginationController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAccounts(String searchKey, String direction, Id lastId, Integer pageSize) {
        Map<String, Object> result = new Map<String, Object>();

        String safeSearch = String.isBlank(searchKey) ? '%' : '%' + String.escapeSingleQuotes(searchKey) + '%';
        String query = 'SELECT Id, Name, Industry, Phone FROM Account WHERE Name LIKE :safeSearch';

        if (direction == 'next' && lastId != null) {
            query += ' AND Id > :lastId ORDER BY Id ASC LIMIT :pageSize';
        } else if (direction == 'previous' && lastId != null) {
            query += ' AND Id < :lastId ORDER BY Id DESC LIMIT :pageSize';
        } else {
            query += ' ORDER BY Id ASC LIMIT :pageSize';
        }

        List<Account> accList = Database.query(query);

        if (direction == 'previous' && accList.size() > 1) {
            List<Account> reversedList = new List<Account>();
            for (Integer i = accList.size() - 1; i >= 0; i--) {
                reversedList.add(accList[i]);
            }
            accList = reversedList;
        }

        result.put('records', accList);
        result.put('size', accList.size());
        return result;
    }
}