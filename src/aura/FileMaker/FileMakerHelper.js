({
    //get account associated with user
	populateAccountId : function(component) {
		var action = component.get("c.getAccount");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set("v.accountId", response.getReturnValue().Id);

            }
            else if (state === "INCOMPLETE") {
                this.showErrorToast("Error occurred",'Incomplete operation');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        this.showErrorToast("Error occurred",errors[0].message);
                    }
                    else{
                        this.showErrorToast("Error occurred",'');
                    }
                } else {
                    console.log("Unknown error");
                    this.showErrorToast("Error occurred",'');
                }
            }
        });
        $A.enqueueAction(action);
    },
    //get the data about number of users, amount and top rows
    getFileData : function(component,contentDocumentId,caseRecordId){
        var action = component.get("c.getFileData");
         action.setParams({ documentId : contentDocumentId, caseId : caseRecordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				 component.set("v.showResult", true); 
                 component.set("v.userCount", response.getReturnValue().userCount);
                 component.set("v.totalAmount", response.getReturnValue().totalAmount);
                 component.set("v.rows", response.getReturnValue().rows);
                 
            }
            else if (state === "INCOMPLETE") {
                this.showErrorToast("Error occurred",'Incomplete operation');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        this.showErrorToast("Error occurred",errors[0].message);
                    }
                    else{
                        this.showErrorToast("Error occurred",'');
                    }
                } else 
                {
                    this.showErrorToast("Error occurred",'');
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    showErrorToast : function(title,errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message:errorMessage,
            type: 'error',
        });
        toastEvent.fire();
    },
})