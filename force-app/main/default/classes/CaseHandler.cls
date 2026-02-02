public without sharing class CaseHandler {
    public static void handleUpdate (List<Case> caseList, Map<Id,Case> oldCase) {
        
        if (caseList == null || caseList.isEmpty()) return;
        List<Case> structuralCases = new List<Case>();
        List<Case> caseToUpdate = new List<Case>();
        /*
String currentUser = [SELECT Profile.Name FROM User WHERE Id =:UserInfo.getUserId()].Profile.Name;
System.debug('currentUser'+currentUser);
if (currentUser == 'System Administrator') return;
*/
        for (Case c : caseList) {
            Case cs = oldCase !=null? oldCase.get(c.Id):null;
            if (c.Type == 'Structural' && cs!=null &&  cs.Type != 'Structural') {
                structuralCases.add(c);
            }
            else if (c.Type == 'Structural' && cs ==null){
                structuralCases.add(c);
                
            }
        }
        
        if (structuralCases.isEmpty()) return;
        
        List<Group> publicGroups = [
            SELECT Id, Name FROM Group WHERE DeveloperName  = 'priviledge_Group' AND Type = 'Regular' LIMIT 1
        ];
		 User systemAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = True LIMIT 1];

        List<CaseShare> shareList = new List<CaseShare>();
        for(case cs : structuralCases) {
            CaseShare cShare = new CaseShare();
            cShare.CaseId = cs.Id;
            cShare.UserOrGroupId = publicGroups[0].Id;
            cShare.CaseAccessLevel = 'Edit';
            cShare.Rowcause = Schema.CaseShare.RowCause.Manual;
            shareList.add(cShare);    
            
        }
        if(!shareList.isEmpty()) {
            insert shareList;
        }
        for(Case c: structuralCases) {
            Case ca = new case();
            ca.Id = c.Id;
            ca.OwnerId = systemAdmin.Id;
            caseToUpdate.add(ca);
        }
        update caseToUpdate;
    }
}