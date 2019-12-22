@isTest
public with sharing class TestDataFactory {
    public static User createUser(Id profileId){
        Integer random = Integer.valueOf(Math.random() * 300);
        User tempUser = new User();
        tempUser.UserName = 'testmaker'+random+'@atvol.com';
        tempUser.Email = 'testmaker@atvol.com';
        tempUser.FirstName = 'First';
        tempUser.LastName = 'Last';
        tempUser.Alias = 'temp';
        tempUser.TimeZoneSidKey = 'Asia/Kolkata';
        tempUser.LocaleSidKey = 'en_IN';
        tempUser.EmailEncodingKey = 'ISO-8859-1';
        tempUser.LanguageLocaleKey = 'en_US';
        tempUser.ProfileId = profileId;

        insert tempUser;
        return tempUser;
    }
    public static Profile getProfileByName(String pName){
        List<Profile> pList = [ SELECT Id FROM Profile WHERE Name = :pName];
        return pList[0];
    }
    public static ContentDocument getCsvFile(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Document';
        cv.PathOnClient = 'User.csv';
        cv.VersionData = Blob.valueOf('Name,Amount\nuser1,100\nuser2,200');
        cv.IsMajorVersion = true;
        insert cv;
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.debug(cdList);
        return cdList[0];
    }
    public static Case createCaseWithFileAttached(String status,String approvalStatus){
        Case fileCase = new Case();
        fileCase.Status = 'Draft';
        fileCase.Subject = 'Users.csv';
        fileCase.Number_of_Users__c = 2;
        fileCase.Total_amount__c = 200;
        if(String.isNotBlank(approvalStatus)){
            fileCase.Approval_Status__c = approvalStatus;
        }
        insert fileCase;
        ContentDocument cd =  getCsvFile();
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = fileCase.Id;
        cdl.ContentDocumentId = cd.Id;
        cdl.ShareType = 'V';
        insert cdl;
        return fileCase;
    }
    public static void addUserToGroup(User u,String groupName){
        Group grp = [SELECT Id FROM Group WHERE Name = :groupName];
        GroupMember groupMember = new GroupMember();
        groupMember.UserOrGroupId = u.Id;
        groupMember.GroupId = grp.Id;
        insert groupMember;
    }
    public static User getMakerUser(){
        Profile makerProfile = getProfileByName('Maker');
        User makerUser = TestDataFactory.createUser(makerProfile.Id);
        addUserToGroup(makerUser,'Maker');   
        return makerUser;
    }
    public static User getCheckerUser(){
        Profile checkerProfile = getProfileByName('Checker');
        User checkerUser = createUser(checkerProfile.Id);
        addUserToGroup(checkerUser,'Checker');
        return checkerUser;
    }
    public static ContentDocument getInvalidNameCsvFile(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Document';
        cv.PathOnClient = 'User.csv';
        cv.VersionData = Blob.valueOf('Namea,Amount\nuser1,100\nuser2,200');
        cv.IsMajorVersion = true;
        insert cv;
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.debug(cdList);
        return cdList[0];
    }
    public static ContentDocument getInvalidAmountCsvFile(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Document';
        cv.PathOnClient = 'User.csv';
        cv.VersionData = Blob.valueOf('Name,mount\nuser1,100\nuser2,200');
        cv.IsMajorVersion = true;
        insert cv;
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.debug(cdList);
        return cdList[0];
    }
}