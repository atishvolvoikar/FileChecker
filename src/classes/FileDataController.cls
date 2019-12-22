public with sharing class FileDataController {
    //Get user profile data
    @AuraEnabled
    public static User getUserData(){
        User u;
        try{
            u = DataHandler.getUser();
        }
        catch(Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException('Error occurred while fetching user');
        }
        return u;        
    }
    //Fetch all files with particular status to which user has access
    @AuraEnabled
    public static List<CaseWrapper> getFilesByType(String status){
        List<CaseWrapper> fileData = new List<CaseWrapper>();
        try{
            List<Case> caseList = DataHandler.getCaseListByStatus(status);
            //get content version ids
            Map<Id,Id> fileIdMap = getFileIdMap(caseList);
            for(Case c : caseList){
                fileData.add(new CaseWrapper(c,fileIdMap.get(c.Id)));
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException('Error occurred while fetching file data');
        }
        return fileData;
    }
    //Approve file
    @AuraEnabled
    public static void approveFile(String caseId){
        try{
            Case fileCase = DataHandler.getCaseById(caseId);
            fileCase.Status = 'Approved';
            fileCase.Approval_Status__c = 'Approved';
            DataHandler.updateCase(new List<Case>{fileCase});
        }
        catch(Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException('Error occurred while approving file');
        }
    }
    //Reject file
    @AuraEnabled
    public static void rejectFile(String caseId){
        try{
            Case fileCase = DataHandler.getCaseById(caseId);
            fileCase.Status = 'Draft';
            fileCase.Approval_Status__c = 'Rejected';
            DataHandler.updateCase(new List<Case>{fileCase});
        }
        catch(Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException('Error occurred while rejecting file');
        }
    }
    //Set case status to approval
    @AuraEnabled
    public static void submitForApproval(String caseId){
        try{
            Case fileCase = DataHandler.getCaseById(caseId);
            fileCase.Status = 'Approval';
            DataHandler.updateCase(new List<Case>{fileCase});
        }
        catch(Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException('Error occurred while submitting file for approval');
        }
    }
    //helper method for getting latest file id for cases
    public static Map<Id,Id> getFileIdMap(List<Case> caseList){
        Map<Id,Id> idMap = new Map<Id,Id>();
        List<Id> idList = new List<Id>();
        for(Case c : caseList){
            idList.add(c.Id);
        }
        List<ContentDocumentLink> cdList = DataHandler.getContentDocumentLinks(idList);
        for(ContentDocumentLink cd : cdList){
            if(!idMap.containsKey(cd.LinkedEntityId)){
                idMap.put(cd.LinkedEntityId,cd.ContentDocumentId);
            }
        }
        return idMap;
    }
    //Wrapper class for displaying case info 
    public class CaseWrapper{
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Decimal userCount {get;set;}
        @AuraEnabled public Decimal totalAmount {get;set;}
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String fileId {get;set;}
        @AuraEnabled public String approvalStatus {get;set;}
        @AuraEnabled public String ownerName {get;set;}

        public CaseWrapper(Case c,String fileId){
            this.name = c.Subject;
            this.userCount = c.Number_Of_Users__c;
            this.totalAmount = c.Total_Amount__c;
            this.Id = c.Id;
            this.ownerName = c.Owner.Name;
            this.approvalStatus =c.Approval_Status__c;
            this.fileId = fileId;
        }
    }
}