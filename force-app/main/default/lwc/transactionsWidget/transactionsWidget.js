import { LightningElement, wire, api } from 'lwc';
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import FILTER from '@salesforce/messageChannel/widgetFilter__c';
import searchTransactions from '@salesforce/apex/TransactionsWidgetController.searchTransactions';
import { context } from 'c/widgetFilterContextCache';

const columns = [
    { label: 'Date', fieldName: 'Transaction_Time__c', type: 'date', sortable: true, typeAttributes: { year: 'numeric', month: 'short',  day: '2-digit', hour: '2-digit', minute: '2-digit' } },
    { label: 'Name', fieldName: 'Counterparty_Name__c', sortable: true},
    { label: 'Type', fieldName: 'Transaction_Type__c', type: 'url', typeAttributes: { label: { fieldName: 'Transaction_Type__c' } } , sortable: true},
    { label: 'Status', fieldName: 'Transaction_Status__c', sortable: true},
    { label: 'Gross', fieldName: 'Gross_Amount__c', sortable: true, type: 'currency', typeAttributes: { currencyCode: { fieldName: 'Gross_Amount_Currency_Code__c' } }},
    { label: 'Fee', fieldName: 'Fee_Amount__c', sortable: true, type: 'currency', typeAttributes: { currencyCode: { fieldName: 'Fee_Amount_Currency_Code__c' } } },
    { label: 'Net Balance', fieldName: 'Net_Amount__c', sortable: true, type: 'currency', typeAttributes: { currencyCode: { fieldName: 'Net_Amount_Currency_Code__c' } }},
    { label: 'Balance', fieldName: 'Running_Balance_Amount__c', sortable: true, type: 'currency', typeAttributes: { currencyCode: { fieldName: 'Running_Balance_Amount_Currency_Code__c' } }},
];

const filterableFields = ['Transaction_Type__c', 'Counterparty_Name__c', 'Counterparty_Email__c', 'Transaction_Status__c', 'Gross_Amount__c', 'Fee_Amount__c', 'Net_Amount__c', 'Running_Balance_Amount__c'];

export default class TransactionsWidget extends LightningElement {
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
    transactions;

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
        this.contextId = context.id? context.id : contextId;
        if(this.contextId != null){
            this.loadTransactions(this.contextId, this.startDate, this.endDate);
        } else {
            this.loading = false;
        }
    }

    loadTransactions(contextId, startDate, endDate) {
        if(this.contextId != null){
            this.loading = true;
            this.error = null;
            searchTransactions({
                    contextId: contextId,
                    startDate: startDate, 
                    endDate: endDate
                })
                .then(result => {
                    this.transactions = result;
                    this.filterRecords(this.transactions);
                    this.sortDirection = 'desc';
                    this.sortedBy = 'Transaction_Time__c';
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
            this.loadTransactions(this.contextId, this.startDate, this.endDate);
        } else if (this.searchFilter != message.keyword) {
            this.searchFilter = message.keyword;
            this.filterRecords(this.transactions, message.keyword);
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