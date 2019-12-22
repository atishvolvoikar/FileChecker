@isTest
public with sharing class FileMakerControllerTest {
    @isTest
    public static void getAccountTest(){
        User makerUser = TestDataFactory.getMakerUser();
        
        Test.startTest();
        System.runAs(makerUser){
            Account acc = FileMakerController.getAccount();
            System.assertEquals(acc.User__c,makerUser.Id,'Users do not match');
        }
        Test.stopTest();    
    }
     @isTest
    public static void getAccountTestPrePopulated(){
        User makerUser = TestDataFactory.getMakerUser();
        
        Test.startTest();
        System.runAs(makerUser){
            Account a = new Account();
            a.Name = makerUser.FirstName +' '+makerUser.LastName;
            a.User__c = makerUser.Id;
            insert a;
            Account acc = FileMakerController.getAccount();
            System.assertEquals(acc.User__c,makerUser.Id,'Users do not match');
        }
        Test.stopTest();    
    }
    @isTest
    public static void getFileDataTestWithoutCase(){
        User makerUser = TestDataFactory.getMakerUser();
       
        Test.startTest();
        System.runAs(makerUser){
             ContentDocument cd = TestDataFactory.getCsvFile();
            FileMakerController.Response res = FileMakerController.getFileData(cd.Id,'');
            System.assertEquals(res.userCount,2,'User count do not match');
            System.assertEquals(res.totalAmount,300,'total amount do not match');
        }
        Test.stopTest();  
    }
    @isTest
    public static void getFileDataTestWithCase(){
        User makerUser = TestDataFactory.getMakerUser();
        
        Test.startTest();
        System.runAs(makerUser){
            ContentDocument cd = TestDataFactory.getCsvFile();
            Case fileCase = new Case();
            fileCase.Status = 'Draft';
            fileCase.Subject = 'Users.csv';
            fileCase.Number_of_Users__c = 10;
            fileCase.Total_amount__c = 100;
            insert fileCase;
            FileMakerController.Response res = FileMakerController.getFileData(cd.Id,fileCase.Id);
            System.assertEquals(res.userCount,2,'User count do not match');
            System.assertEquals(res.totalAmount,300,'total amount do not match');
            Case c = [ SELECt Number_of_Users__c,Total_amount__c FROM Case WHERE Id = : fileCase.Id ];
            System.assertEquals(res.userCount,c.Number_of_Users__c,'User count do not match');
            System.assertEquals(res.totalAmount,c.Total_amount__c,'total amount do not match');
        }
        Test.stopTest();  
    }
    @isTest
    public static void getFileDataTestWithInvalidDocId(){
        User makerUser = TestDataFactory.getMakerUser();
        Test.startTest();
        System.runAs(makerUser){
            Boolean flag = false;
            try{
                FileMakerController.Response res = FileMakerController.getFileData('','');
            }
            catch(AuraHandledException e){
                flag = true;
            }
            System.assertEquals(true,flag,'Exception not thrown');
        }
        Test.stopTest();  
    }
    @isTest
    public static void missingNameColumnTest(){
        User makerUser = TestDataFactory.getMakerUser();
       
        Test.startTest();
        System.runAs(makerUser){
            Boolean flag = false;
            try{
                ContentDocument cd = TestDataFactory.getInvalidNameCsvFile();
                FileMakerController.Response res = FileMakerController.getFileData(cd.Id,'');
            }
            catch(AuraHandledException e){
               flag = true;   
            }
            System.assertEquals(flag,true,'Exception not thrown');
        }
        Test.stopTest();  
    }
    @isTest
    public static void missingAmountColumnTest(){
        User makerUser = TestDataFactory.getMakerUser();
       
        Test.startTest();
        System.runAs(makerUser){
            Boolean flag = false;
            try{
                ContentDocument cd = TestDataFactory.getInvalidAmountCsvFile();
                FileMakerController.Response res = FileMakerController.getFileData(cd.Id,'');
            }
            catch(AuraHandledException e){
               flag = true;   
            }
            System.assertEquals(flag,true,'Exception not thrown');
        }
        Test.stopTest();  
    }
}