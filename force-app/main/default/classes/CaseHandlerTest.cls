@isTest
public class CaseHandlerTest {
	@isTest
    static void testHandleUpdate() {
        
        Profile psu = [SELECT Id FROM Profile WHERE Name ='System Administrator' LIMIT 1];

        User u = new user();
        u.LastName = 'TestCode1';
        u.Email = 'example1@example.com';
        u.Alias = 'Tcode1';
        u.Username = 'TestCode1@example.com';
        u.CommunityNickname = 'test1211';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = psu.id;
        u.LanguageLocaleKey = 'en_US';
        u.IsActive = true;
        u.EmailEncodingKey = 'UTF-8';
        insert u;
        
        Group gp = new Group();
        gp.Name = 'Test Group';
        gp.DeveloperName = 'test_Group';
        gp.Type = 'Regular';
        insert gp;
        
        Case c1 = new Case();
        c1.Subject = 'Old Case';
        c1.Type = 'Electronics';
        c1.Status = 'New';
        insert c1;
        
        Case c2 = c1.clone(false,false,false,false);
        insert c2;
        c2.Type = 'Structural';
        update c2;
        
        List<Case> caseList = new List<Case>{ c1 };
		Map<Id, Case> oldCaseMap = new Map<Id, Case>(caseList);
        
        Test.startTest();
        CaseHandler.handleUpdate(new List<Case>{c2}, oldCaseMap);
        Test.stopTest();
    }
}