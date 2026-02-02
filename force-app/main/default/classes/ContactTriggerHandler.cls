public class ContactTriggerHandler {

    public static void preventDuplicateContact(List<Contact> conList) {

        Set<Id> accountIdSet = new Set<Id>();
        Set<String> emailSet = new Set<String>();
        Set<String> existingKeys = new Set<String>();

        for (Contact con : conList) {
            if (con.AccountId != null && con.Email != null) {
                accountIdSet.add(con.AccountId);
                emailSet.add(con.Email.toLowerCase());
            }
        }

        if (accountIdSet.isEmpty()) return;

        for (Contact con : [
            SELECT AccountId, Email
            FROM Contact
            WHERE AccountId IN :accountIdSet
            AND Email IN :emailSet
        ]) {
            existingKeys.add(con.AccountId + ' ' + con.Email.toLowerCase());
        }

        for (Contact newCon : conList) {
            if (newCon.AccountId != null && newCon.Email != null) {
                String key = newCon.AccountId + ' ' + newCon.Email.toLowerCase();
                if (existingKeys.contains(key)) {
                    newCon.Email.addError('Email Already Exist');
                }
            }
        }
    }
}