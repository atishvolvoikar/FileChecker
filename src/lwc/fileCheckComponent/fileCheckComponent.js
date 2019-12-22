import { LightningElement,track } from 'lwc';
import getUserData from '@salesforce/apex/FileDataController.getUserData';
import getFilesByType from '@salesforce/apex/FileDataController.getFilesByType';

import submitForApproval from '@salesforce/apex/FileDataController.submitForApproval';
import acceptFile from '@salesforce/apex/FileDataController.approveFile';
import rejectFile from '@salesforce/apex/FileDataController.rejectFile';
//Options
const draftOption = { label: 'Draft', value: 'Draft' };
const unverifiedOption = { label: 'Unverified', value: 'Approval' };
const approvedOption = { label: 'Approved', value: 'Approved' };

//columns
const approvalHistoyCol  = {   label: 'Approval History', fieldName: 'approvalStatus', type : 'text' };
const numberOfUsersCol =  {   label: 'No.of users', fieldName: 'userCount' , type : 'number'}; 
const totalAmountCol = {   label: 'Total amount', fieldName: 'totalAmount', type : 'number' }; 
const ownerNameCol =  {   label: 'Owner', fieldName: 'ownerName', type : 'text' }
//column actions
const submitForApprovalBtn = {   type : 'button', label :'Submit for Approval', typeAttributes : { label: 'Submit', name :'submit_approval', title : 'Click to submit for approval' }} ;
const approveFileBtn = {   type : 'button', label :'Approve', typeAttributes : { label: 'Approve', name :'approve_file', title : 'Click to approve file' }} ;
const rejectFileBtn = {   type : 'button', label :'Reject', typeAttributes : { label: 'Reject', name :'reject_file', title : 'Click to reject file' }} ;
const reuploadFileBtn = {   type : 'button', label :'Reupload', typeAttributes : { label: 'Reupload', name :'reupload_file', title : 'Click to reupload file' }} ;
const downloadFileBtn = {   type : 'button', label :'Download', typeAttributes : { label: 'Download', name :'download_file', title : 'Click to download file' }} ;

const columnSysAdmin = {
    "Approval" : [
        approvalHistoyCol,
        numberOfUsersCol,
        totalAmountCol,
        ownerNameCol, 
        approveFileBtn,
        rejectFileBtn,
        downloadFileBtn
        ],
    "Draft" : [
        approvalHistoyCol,
        numberOfUsersCol,
        totalAmountCol,
        ownerNameCol,
        submitForApprovalBtn, 
        reuploadFileBtn,
        downloadFileBtn,  
        ],
    "Approved" : [
        approvalHistoyCol,
        numberOfUsersCol,
        totalAmountCol,
        ownerNameCol,
        downloadFileBtn
        ],
    };
const columnChecker = {
    "Approval" : [
        approvalHistoyCol,
        numberOfUsersCol,
        totalAmountCol,
        ownerNameCol, 
        approveFileBtn,
        rejectFileBtn,
        downloadFileBtn
        ],
    "Approved" : [
        approvalHistoyCol,
        numberOfUsersCol,
        totalAmountCol,
        ownerNameCol, 
        downloadFileBtn
        ],

};
const columnMaker = {
    "Approval" : [
        approvalHistoyCol,
        numberOfUsersCol,
        totalAmountCol,
        ownerNameCol,
        downloadFileBtn
        ],
    "Draft" : [
        approvalHistoyCol,
        numberOfUsersCol,
        totalAmountCol,
        ownerNameCol,
        submitForApprovalBtn,  
        reuploadFileBtn,
        downloadFileBtn 
        ],
    "Approved" : [
        approvalHistoyCol,
        numberOfUsersCol,
        totalAmountCol,
        ownerNameCol, 
        downloadFileBtn
        ],
};

const columnObj = {
        "System Administrator" : columnSysAdmin,
        "Checker" : columnChecker,
        "Maker" : columnMaker,
    }
const optionObj = {
        "System Administrator" : [draftOption,unverifiedOption,approvedOption],
        "Checker" : [unverifiedOption,approvedOption],
        "Maker" : [draftOption,unverifiedOption,approvedOption],
}   
const defaultOption = {
    "System Administrator" : draftOption.value,
    "Checker" :  unverifiedOption.value,
    "Maker" :  draftOption.value,
} 
export default class FileCheckComponent extends LightningElement {
    profileName;
    @track selectedOption;
    @track columns;
    @track options
    @track data;
    connectedCallback(){
        getUserData()
        .then( response => {
            this.profileName = response.Profile.Name;
            this.selectedOption = defaultOption[this.profileName];
            this.options = optionObj[this.profileName];
            this.columns = this.getColumn(this.profileName,this.selectedOption);
            this.getFileData();
         })
         .catch((error) => {
            this.toastError(error, "Error occurred while getting user data");
        })
    }
    handleChange(event){
        this.selectedOption = event.detail.value;
        this.columns = this.getColumn(this.profileName,this.selectedOption);
        this.getFileData();
    }
    getFileData(){
        getFilesByType({ status : this.selectedOption })
        .then( response =>{
            this.data = response;
        })
        .catch((error) => {
            this.toastError(error, "Error occured while getting data");
        })
    }
    getColumn(profileName,status){
        return columnObj[profileName][status];
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'submit_approval':
                this.submitFileForApproval(row);
                break;
            case 'approve_file':
                this.acceptFileApproval(row);
                break;
            case 'reject_file':
                this.rejectFileApproval(row);
                break;
            case 'reupload_file':
                this.reupload(row);
                break;
            case 'download_file':
                this.downloadFile(row);
                break;
            default:
        }
    }
    submitFileForApproval(row){
        submitForApproval({caseId : row.Id })
        .then( response =>{
            this.getFileData();
        })
        .catch((error) => {
            this.toastError(error, "Error occured during approval submission");
        })
    }
    acceptFileApproval(row){
        acceptFile({caseId : row.Id })
        .then(response => {
            this.getFileData();
        })
        .catch((error) => {
            this.toastError(error, "Error occured during approval");
        })
    }
    rejectFileApproval(row){
        rejectFile({caseId : row.Id })
        .then(response => {
            this.getFileData();
        })
        .catch((error) => {
            this.toastError(error, "Error occured during rejection");
        })
    }
    reupload(row){
        const caseRecordId = row.Id;
        const reuploadEvent = new CustomEvent('reupload', {
            detail: { caseRecordId },
        });
        // Fire the custom event
        this.dispatchEvent(reuploadEvent);
    }
    downloadFile(row){
       let url =  '/sfc/servlet.shepherd/document/download/'+row.fileId;
       window.open(url,'_blank');
    }
    toastError(error, title) {
        let errorMsg = '';
        if (error !== undefined && error.body !== undefined && Array.isArray(error.body)) {
            errorMsg = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            errorMsg = error.body.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: errorMsg,
                variant: "error"
            })
        );
    }
}