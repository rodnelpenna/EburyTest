import { LightningElement,track,wire } from 'lwc';
import {refreshApex} from '@salesforce/apex';
import getTrades from '@salesforce/apex/MainTradeHelper.getTrades';

const table_columns = [
    { label: 'Sell CCY', fieldName: 'Sell_Currency__c', type: 'text' },
    { label: 'Sell Amount', fieldName: 'Sell_Amount__c', type: 'currency' },
    { label: 'Buy CCY', fieldName: 'Buy_Currency__c', type: 'text' },
    { label: 'Buy Amount', fieldName: 'Buy_Amount__c', type: 'currency' },
    { label: 'Rate', fieldName: 'Rate__c', type: 'currency' },
    { label: 'Date Booked', fieldName: 'Date_Booked__c', type: 'date' }
];

export default class MainTrade extends LightningElement {
    columns = table_columns;
    @track trades;
    tradeMethod;
    @wire(getTrades) 
      tradesToDisplay(result) {
        this.tradeMethod = result;
        if (result.data) {
          this.trades = result.data;
          console.log('trades '+this.trades);
        } else if (result.error) {
          console.log(result.error);
        }
      }
}