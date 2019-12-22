public class FileMakerController {
    final public static Integer TOP_ROW = 5;
    //Get account related to user
    @AuraEnabled
    public static Account getAccount(){
        List<Account> accList = DataHandler.getAccountByUserId();
        if(accList.size() == 0){
            Account a = new Account();
            a.Name = UserInfo.getName();
            a.User__c = UserInfo.getUserId();
            accList = DataHandler.insertAccount(new List<Account>{a});
        }
        return accList[0];
    }
    //get data related to file : user count, total amount, top rows. Update case record to stre these values
    @AuraEnabled
    public static Response getFileData(String documentId,String caseId){
        Response res;
        try{
            List<FileRow> rows = new List<FileRow>();
            Case fileCase;
            //Read file data
            ContentVersion cv = DataHandler.getLatestContentVersion(documentId);
            String csvContents = cv.VersionData.toString();
            String[] csvLines = csvContents.split('\n');
            Integer userCount = csvLines.size() - 1;
            Decimal totalAmount = 0;
            List<String> header = new List<String>();
            for(String col : csvLines[0].split(',')){
                col = col.replace('\n','');
                col = col.replace('\r','');
                header.add(col);
            }
            Integer nameIndex = header.indexOf('Name');
            if( nameIndex == -1 ){
                throw new AuraHandledException('Name column not found');
            }
            Integer amountIndex = header.indexOf('Amount');
            if( amountIndex == -1 ){
                throw new AuraHandledException('Amount column not found');
            }
            for(Integer i = 1; i < csvLines.size();i++){
                String line = csvLines[i];
                String[] vals = line.split(',');     
                totalAmount = totalAmount + Decimal.valueOf(vals[amountIndex].trim());
                if(i <= TOP_ROW ){
                    rows.add(new FileRow(vals[nameIndex].trim(),Decimal.valueOf(vals[amountIndex].trim())));
                }  
            }
            //Get case
            if(String.isNotBlank(caseId)){
                fileCase = DataHandler.getCaseById(caseId);
                fileCase.Number_of_Users__c = userCount;
                fileCase.Total_amount__c = totalAmount;
                DataHandler.updateCase(new List<Case>{fileCase});
            }
            else{
                fileCase = new Case();
                fileCase.Status = 'Draft';
                fileCase.Subject = cv.Title;
                fileCase.Number_of_Users__c = userCount;
                fileCase.Total_amount__c = totalAmount;
                List<Case> insertedCaseList = DataHandler.insertCase(new List<Case>{fileCase});
                fileCase = insertedCaseList[0];
            }
            ContentDocumentLink cd = new ContentDocumentLink();
            cd.LinkedEntityId = fileCase.Id;
            cd.ContentDocumentId = cv.ContentDocumentId;
            cd.ShareType = 'V';
            List<ContentDocumentLink> insertedContDocLinks = DataHandler.insertContentDocumentLink(new List<ContentDocumentLink>{cd});
            res =  new Response(userCount,totalAmount);
            res.rows = rows;
        }
        catch(AuraHandledException e){
            throw e;
        }
        catch(Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException('Error occurred while uploading file');
        }      
        return res;
    }
    //Wrapper class for response
    public class Response{
        @AuraEnabled public Integer userCount{get;set;}
        @AuraEnabled public Decimal totalAmount{get;set;}
        @AuraEnabled public List<FileRow> rows;
        Response(Integer userCount,Decimal amount){
            this.userCount = userCount;
            this.totalAmount = amount;
            this.rows = new List<FileRow>();
        }
    }
    //Wrapper class for row data
    public class FileRow{
        @AuraEnabled public String userName{get;set;}
        @AuraEnabled public Decimal amount{get;set;}
        fileRow(String name,Decimal amount){
            this.userName = name;
            this.amount = amount;
        }   
    }
}