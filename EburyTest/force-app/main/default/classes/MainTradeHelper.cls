public with sharing class MainTradeHelper {

   final static String URL_FIXER_IO = 'https://api.apilayer.com/fixer/latest';
   @TestVisible
   private static String contState;
   @TestVisible
   private static String contlabel;
 
   @AuraEnabled(cacheable = true)
   public static List<Trade__c> getTrades(){
    return [SELECT Id,Sell_Currency__c,Sell_Amount__c,Rate__c,Buy_Currency__c,Buy_Amount__c,Date_Booked__c  FROM Trade__c ORDER BY Date_Booked__c DESC];
   }

   @AuraEnabled(cacheable = true continuation=true)
   public static Object rateRequest(String base, String exchange){
      Continuation con = new Continuation(20);
      con.continuationMethod='rateResponse';

      String fixerEndpoint = URL_FIXER_IO;
      fixerEndpoint += '?base=' + base;
      fixerEndpoint += '&symbols=' + exchange;

      // Create callout request
      HttpRequest req = new HttpRequest();
      req.setMethod('GET');
      req.setEndpoint(fixerEndpoint);
      req.setHeader('apikey', 'bbK6hlWdYVsU4rFikPiDVysRy6XJjYYB');

      contState = con.addHttpRequest(req);
      contlabel ='this is for test';
      con.state = contState;
      return con;
   }

   @AuraEnabled(cacheable = true)
   public static Object rateResponse(List<String> labels, Object state) {
      HttpResponse response = Continuation.getResponse(labels[0]);
      System.debug('Response: ' + response.getBody());
      if(response.getStatusCode() == 200) {
         Map<String,Object> result = ( Map<String,Object>)JSON.deserializeUntyped(response.getBody());         

         return result.get('rates');
      } else {
         return null;
      }     
   }

   @AuraEnabled
   public static List<String> getGlobalPicklist(){
      List<String>  values = new List<String>();
      List<PicklistSource__mdt> picklistNames = [SELECT SObject_Field__c,SObject_Name__c FROM PicklistSource__mdt];
      if(picklistNames.size() > 0){
         List<Schema.PicklistEntry> ple = Schema.getGlobalDescribe().get(picklistNames[0].SObject_Name__c).getDescribe().fields.getMap().get(picklistNames[0].SObject_Field__c).getDescribe().getPicklistValues();
         for(Schema.PicklistEntry p : ple){
            if(p.isActive()){
               values.add(p.getLabel());
            }
         }
         return values;
      }
      return new List<String>();
   }

    @AuraEnabled
    public static String createTrade(String sellCurrency, String buyCurrency, String sellAmount, String rate){
      Trade__c trade = new Trade__c();
      trade.Sell_Currency__c = sellCurrency;
      trade.Buy_Currency__c = buyCurrency;
      trade.Sell_Amount__c = Decimal.valueOf(sellAmount);
      trade.Date_Booked__c = Datetime.now();
      trade.Rate__c = Decimal.valueOf(rate);
      if(Test.isRunningTest()){
         trade.BypassFlow__c = true;
      }   

      Database.SaveResult result = Database.insert(trade, false);
      if(result.isSuccess()){
            return 'Success';
      }else{
         String errorMessage = 'Error ';
         for(Database.Error error : result.getErrors()){
            errorMessage += error.getMessage() + ' ';
         }
            return errorMessage;
      }
    }
}