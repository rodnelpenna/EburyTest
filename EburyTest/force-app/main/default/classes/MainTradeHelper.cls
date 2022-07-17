public with sharing class MainTradeHelper {
   @AuraEnabled(cacheable = true)
   public static List<Trade__c> getTrades(){
    return [SELECT Id,Sell_Currency__c,Sell_Amount__c,Rate__c,Buy_Currency__c,Buy_Amount__c,Date_Booked__c  FROM Trade__c ORDER BY Date_Booked__c DESC];
   }
}
