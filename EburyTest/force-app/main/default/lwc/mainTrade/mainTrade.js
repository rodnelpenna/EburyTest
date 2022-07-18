import { LightningElement,track,wire } from 'lwc';
import getTrades from '@salesforce/apex/MainTradeHelper.getTrades';
import createTemplate from './createTab.html';
import mainTemplate from './mainTrade.html';
import getGlobalPicklist from '@salesforce/apex/MainTradeHelper.getGlobalPicklist';
import  rateRequest from '@salesforce/apexContinuation/MainTradeHelper.rateRequest';
import createTrade from '@salesforce/apex/MainTradeHelper.createTrade';

const METADATA_FIELDS = [
  'TradeRecordType__mdt.RecordTypeId__c',
  'TradeRecordType__mdt.RecordTypeName__c'
];

const TABLE_COLUMNS = [
  { label: 'Sell CCY', fieldName: 'Sell_Currency__c', type: 'text' },
  { label: 'Sell Amount', fieldName: 'Sell_Amount__c', type: 'currency' },
  { label: 'Buy CCY', fieldName: 'Buy_Currency__c', type: 'text' },
  { label: 'Buy Amount', fieldName: 'Buy_Amount__c', type: 'currency' },
  { label: 'Rate', fieldName: 'Rate__c', type: 'currency' },
  { label: 'Date Booked', fieldName: 'Date_Booked__c', type: 'date' }
];

export default class MainTrade extends LightningElement {
  columns = TABLE_COLUMNS;
  @track trades;
  @track sell_amount;
  @track buy_amount;
  @track currency_picklist;
  trade_method;
  show_create_tab = false;
  
  buy_currency_value;
  sell_currency_value;
  @track rate = '0';


  @wire(getTrades) 
    tradesToDisplay(result) {
      this.trade_method = result;
      if (result.data) {
        this.trades = result.data;
        console.log('trades '+this.trades);
      } else if (result.error) {
        console.log(result.error);
      }
    }

  render(){
    if(this.show_create_tab){
      return createTemplate;
    }else{
      return mainTemplate;
    }
  }
    
  showCreateTab(event) {
    this.show_create_tab = true;
  }
  showMainTab(event) {
    this.show_create_tab = false;
  }
 
  connectedCallback() {
    getGlobalPicklist().then(result => {
      console.log('result',result);
      this.currency_picklist = [];
      result.forEach(element => {
        this.currency_picklist.push({label: element, value: element});
      });
      this.currency_picklist = JSON.parse(JSON.stringify(this.currency_picklist))
      console.log('picklist',this.currency_picklist);
    }).catch(error => {
      console.log(error);
    })
  }

  handleSellAmountChange(event){ 
      this.sell_amount = event.target.value;
      this.buy_amount = this.sell_amount * this.rate;
  }

  createTradeHandler(event){
    console.log('event',event);
    this.show_create_tab = false;
    createTrade({
        sellCurrency: this.sell_currency_value, 
        buyCurrency: this.buy_currency_value, 
        sellAmount: this.sell_amount,
        rate: this.rate}).then(result => {
          console.log('result ',result);
        })
  }
   
  handleBuyChange(event){
    this.buy_currency_value = event.target.value;
    if(this.buy_currency_value && this.sell_currency_value){
      rateRequest({base: this.buy_currency_value, exchange: this.sell_currency_value})
      .then((result) => {
        console.log('result',result);
        this.rate = Object.values(result)[0];
      }).catch((error) => {
        console.log(error);
      });
    }
  }

  handleSellChange(event){
    this.sell_currency_value = event.target.value;
    if(this.buy_currency_value && this.sell_currency_value){
      rateRequest({base: this.buy_currency_value, exchange: this.sell_currency_value})
      .then((result) => {
        console.log('result',result);
        this.rate =  Object.values(result)[0];
      }).catch((error) => {
        console.log(error);
      });
    }
  }

}