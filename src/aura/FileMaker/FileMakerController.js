({
	doInit : function(component, event, helper) {
		component.set("v.showResult", false);
        helper.populateAccountId(component);
        var columns = [
            {label: 'User Name', fieldName: 'userName', type: 'text'},
            {label: 'Amount', fieldName: 'amount', type: 'number'},
        ];
        component.set("v.columns",columns)
	},
    handleUploadFinished: function (component, event, helper) {
        // Get the list of uploaded files
        var isReupload = component.get("v.isReupload");;
        var caseRecordId = component.get("v.caseRecordId");
        var uploadedFiles = event.getParam("files");
        if(isReupload){
            helper.getFileData(component,uploadedFiles[0].documentId,caseRecordId);
        }
        else{
            helper.getFileData(component,uploadedFiles[0].documentId,'');
        }

    },
    handleUploadNew : function (component, event, helper) {
        component.set("v.showModal", true);
    },
    handleReupload : function (component, event, helper) {
        var caseRecordId = event.getParam('caseRecordId');
        component.set('v.caseRecordId', caseRecordId);
        component.set("v.isReupload", true);
        component.set("v.showModal", true);
    },
    closeModal : function (component, event, helper) {
        component.set("v.showModal", false);
        component.set("v.showResult", false);
        component.set("v.isReupload",false);
        component.set("v.caseRecordId",'');
        $A.get('e.force:refreshView').fire();
    },

})