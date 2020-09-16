import { LightningElement, wire, api } from 'lwc';
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import FILTER from '@salesforce/messageChannel/widgetFilter__c';
import searchCases from '@salesforce/apex/CaseWidgetController.searchCases';
import { context } from 'c/widgetFilterContextCache';

const columns = [
    { label: 'Case ID', fieldName: 'Case_Id__c', type: 'url', typeAttributes: { label: { fieldName: 'Case_Id__c' } }},
    { label: 'Type', fieldName: 'Case_Type__c', sortable: true},
    { label: 'Category', fieldName: 'Party__c', sortable: true},
    { label: 'Status', fieldName: 'Case_Status__c', sortable: true},
    { label: 'Created Date', fieldName: 'Time_Created__c', sortable: true, type: 'date', typeAttributes: { year: 'numeric', month: 'short',  day: '2-digit', hour: '2-digit', minute: '2-digit' } },
];

const filterableFields = ['Case_Id__c', 'Case_Type__c', 'Party__c', 'Case_Status__c'];

export default class CaseWidget extends LightningElement {
    @wire(MessageContext)
    messageContext;

    @api contextId;

    startDate;
    endDate;
    searchFilter;

    loading = true;

    columns = columns;
    data;
    error;
    cases;

    defaultSortDirection = 'desc';
    sortDirection = 'desc';
    sortedBy;

    subscription = null;

    get noDataFound() {
        return !this.noContextId && !this.loading && !this.error && this.data && this.data.length == 0;
    }

    get noContextId() {
        return typeof this.contextId === 'undefined' || this.contextId == null || this.contextId.length == 0;
    }    

    connectedCallback() {
        this.subscribeMC();
        this.startDate = context.startDate;
        this.endDate = context.endDate;
        this.contextId = context.id? context.id : this.contextId;
        if(this.contextId != null){
            this.loadCases(this.contextId, this.startDate, this.endDate);
        } else {
            this.loading = false;
        }
    }

    loadCases(contextId, startDate, endDate) {
        if(this.contextId != null){
            this.loading = true;
            this.error = null;
            searchCases({
                    contextId: contextId,
                    startDate: startDate, 
                    endDate: endDate
                })
                .then(result => {
                    this.cases = result;
                    this.filterRecords(this.cases);
                    this.sortDirection = 'desc';
                    this.sortedBy = 'Time_Created__c';
                    this.loading = false;
                })
                .catch(error => {
                    // Handle Server Errors
                    this.loading = false;
                    this.error = error;
                });
        }
    }

    filterRecords(data, keyword) {
        if(typeof data != 'undefined' && data && typeof keyword != 'undefined' && keyword && keyword != ''){
            this.data = data.filter(d => {
                return filterableFields.some(field => d[field] && d[field].toString().toLowerCase().includes(keyword.toLowerCase()));
            });
        } else {
            this.data = data;
        }
    }

    subscribeMC() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(
            this.messageContext,
            FILTER, (message) => {
                this.handleMessage(message);
            },
            { scope: APPLICATION_SCOPE }
        );
    }  

    handleMessage(message) {
        if(message.startDate != this.startDate || message.endDate != this.endDate){
            this.startDate = message.startDate;
            this.endDate = message.endDate;
            this.loadCases(this.contextId, this.startDate, this.endDate);
        } else if (this.searchFilter != message.keyword) {
            this.searchFilter = message.keyword;
            this.filterRecords(this.cases, message.keyword);
        }
    }


    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}