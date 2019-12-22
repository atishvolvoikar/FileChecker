@isTest
public with sharing class FileDataControllerTest {
    @isTest
    public static void getUserDataTest(){
        Test.startTest();
        User u = FileDataController.getUserData();
        Test.stopTest();
        System.assertEquals(u.Profile.Name,'System Administrator','Profile name do not match');
    }
    @isTest
    public static void getFilesByTypeMakerDraftTest(){
        User makerUser = TestDataFactory.getMakerUser();
        Test.startTest();       
        System.runAs(makerUser){
            Case c = TestDataFactory.createCaseWithFileAttached('Draft','');
            List<FileDataController.CaseWrapper> cdList = FileDataController.getFilesByType('Draft');
            System.assertEquals(cdList.size(),1,'Size do not match');
        }
        Test.stopTest(); 
    }
    @isTest
    public static void makerSubmitForApproval(){
        User makerUser = TestDataFactory.getMakerUser();
      
        Test.startTest();       
        System.runAs(makerUser){
            Case c = TestDataFactory.createCaseWithFileAttached('Draft','');
            FileDataController.submitForApproval(c.Id);
            Case newCase = [ SELECT Status FROM Case WHERE Id = :c.Id];
            System.assertEquals(newCase.Status,'Approval','Approval status do not match');
        }
        Test.stopTest(); 
    }
    @isTest
    public static void submitForApprovalExceptionTest(){
        User makerUser = TestDataFactory.getMakerUser();
        Case c;
        Test.startTest();       
        System.runAs(makerUser){
            Boolean flag = false;
            try{
                FileDataController.submitForApproval('');
            }
            catch(AuraHandledException e){
                flag = true;
            }
            System.assertEquals(true,flag,'Exception not thrown');
        }
        Test.stopTest(); 
    }
    @isTest
    public static void getFileTypeCheckerTest(){
        User makerUser = TestDataFactory.getMakerUser();
        User checkerUser = TestDataFactory.getCheckerUser();
        Test.startTest();       
        System.runAs(makerUser){
            Case c = TestDataFactory.createCaseWithFileAttached('Approval','');
        }
        System.runAs(checkerUser){
            List<FileDataController.CaseWrapper> cdList = FileDataController.getFilesByType('Draft');
            System.assertEquals(cdList.size(),1,'Size do not match');
        }
        Test.stopTest(); 
    }
    @isTest
    public static void approveFileTest(){
        User makerUser = TestDataFactory.getMakerUser();
        User checkerUser = TestDataFactory.getCheckerUser();

        
        Case c;
        Test.startTest();       
        System.runAs(makerUser){
            c = TestDataFactory.createCaseWithFileAttached('Approval','');
        }
        System.runAs(checkerUser){
            FileDataController.approveFile(c.Id);
            Case newCase = [ SELECT Approval_Status__c,Status FROM Case WHERE Id = :c.Id ];
             System.assertEquals(newCase.Approval_Status__c,'Approved','Approval status do not match');
              System.assertEquals(newCase.Status,'Approved','Status do not match');
        }
        Test.stopTest(); 
    }
    @isTest
    public static void approveFileExceptionTest(){
        User makerUser = TestDataFactory.getMakerUser();
        User checkerUser = TestDataFactory.getCheckerUser();
        Case c;
        Test.startTest();       
        System.runAs(makerUser){
            c = TestDataFactory.createCaseWithFileAttached('Approval','');
        }
        System.runAs(checkerUser){
            Boolean flag = false;
            try{
                FileDataController.approveFile('');
            }
            catch(AuraHandledException e){
                flag = true;
            }
            System.assertEquals(true,flag,'Exception not thrown');
        }
        Test.stopTest(); 
    }
    
    @isTest
    public static void rejectFileTest(){
        User makerUser = TestDataFactory.getMakerUser();
        User checkerUser = TestDataFactory.getCheckerUser();
        
        Case c;
        Test.startTest();       
        System.runAs(makerUser){
            c = TestDataFactory.createCaseWithFileAttached('Approval','');
        }
        System.runAs(checkerUser){
            FileDataController.rejectFile(c.Id);
            Case newCase = [ SELECT Approval_Status__c,Status FROM Case WHERE Id = :c.Id ];
             System.assertEquals(newCase.Approval_Status__c,'Rejected','Approval status do not match');
              System.assertEquals(newCase.Status,'Draft','Status do not match');
        }
        Test.stopTest(); 
    }
    
    @isTest
    public static void rejectFileExceptionTest(){
        User makerUser = TestDataFactory.getMakerUser();
        User checkerUser = TestDataFactory.getCheckerUser();
        Case c;
        Test.startTest();       
        System.runAs(makerUser){
            c = TestDataFactory.createCaseWithFileAttached('Approval','');
        }
        System.runAs(checkerUser){
            Boolean flag = false;
            try{
                FileDataController.rejectFile('');
            }
            catch(AuraHandledException e){
                flag = true;
            }
            System.assertEquals(true,flag,'Exception not thrown');
        }
        Test.stopTest(); 
    }
}