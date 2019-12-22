public with sharing class DataHandler {
   public static User getUser(){
       User u = [Select Profile.Name FROM User WHERE Id = :Userinfo.getUserId()];
       return u;
   }
    public static List<Account> getAccountByUserId(){
        List<Account> accList = [ Select Id,User__C FROM Account WHERE User__c = :UserInfo.getUserId()];
        return accList;
    }
    public static List<Account> insertAccount(List<Account> accList){
       insert accList;
       return accList;
    }
    public static List<Case> insertCase(List<Case> caseList){
       insert caseList;
       return caseList;
    }
    public static List<ContentDocumentLink> insertContentDocumentLink(List<ContentDocumentLink> cdList){
       insert cdList;
       return cdList;
    }
    public static void updateCase(List<Case> caseList){
       update caseList;
    }
    public static Case getCaseById(String caseId){
       return [ SELECT Approval_Status__c, Status,Subject
                FROM Case
                WHERE Id = :caseId];
    }
    public static List<Case> getCaseListByStatus(String status){
       List<Case> caseList = [   SELECT Id,Subject,Number_Of_Users__c,Total_Amount__c,Status,Approval_Status__c,Owner.Name 
                                 FROM Case 
                                 WHERE Status = :status ];
      return caseList;
    }
    public static List<ContentDocumentLink>  getContentDocumentLinks(List<Id> idList){
         List<ContentDocumentLink> cdList = [    SELECT ContentDocumentId,LinkedEntityId,ContentDocument.CreatedDate 
                                                FROM ContentDocumentLink
                                                WHERE LinkedEntityId IN :idList
                                                ORDER BY ContentDocument.CreatedDate DESC
                                            ];
         return cdList;
    }
    public static ContentVersion getLatestContentVersion(String documentId){
         ContentVersion cv = [SELECT Title,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :documentId AND IsLatest = true];
         return cv;
    }
}