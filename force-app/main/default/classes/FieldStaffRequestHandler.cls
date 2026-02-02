public class FieldStaffRequestHandler {

    public static void validateLimit(List<Field_Staff_Request__c> requests) {

        Map<String, Integer> approvalCount = new Map<String, Integer>();

        Set<Id> staffIds = new Set<Id>();
        Set<Date> dates = new Set<Date>();
        Set<Id> currentIds = new Set<Id>();

        for (Field_Staff_Request__c r : requests) {
            if (r.Status__c == 'Approved' && r.Staff_Member__c != null && r.Request_Date__c != null) {
                staffIds.add(r.Staff_Member__c);
                dates.add(r.Request_Date__c);
                if (r.Id != null) currentIds.add(r.Id);
            }
        }

        if (staffIds.isEmpty()) return;

        for (Field_Staff_Request__c r : [
            SELECT Staff_Member__c, Request_Date__c
            FROM Field_Staff_Request__c
            WHERE Status__c = 'Approved'
              AND Staff_Member__c IN :staffIds
              AND Request_Date__c IN :dates
              AND Id NOT IN :currentIds
        ]) {
            String key = r.Staff_Member__c + ':' + r.Request_Date__c;
            approvalCount.put(key, approvalCount.get(key) == null ? 1 : approvalCount.get(key) + 1);
        }

        for (Field_Staff_Request__c r : requests) {
            if (r.Status__c != 'Approved' || r.Staff_Member__c == null || r.Request_Date__c == null)
                continue;

            String key = r.Staff_Member__c + ':' + r.Request_Date__c;
            Integer count = approvalCount.get(key) == null ? 0 : approvalCount.get(key);
            count++;

            if (count > 3) {
                r.addError('This staff member has reached the maximum approved requests for this date.');
            } else {
                approvalCount.put(key, count);
            }
        }
    }
}