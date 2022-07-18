@isTest
public class MainTradeHelper_Test {
    
    @TestSetup
    static void makeData(){        
        List<Trade__c> trades= new List<Trade__c>();
        Trade__c trade1 = new Trade__c();
        trade1.Buy_Currency__c = 'USD';
        trade1.Date_Booked__c = Datetime.now();
        trade1.Rate__c = 1.1;
        trade1.Sell_Amount__c = 100;
        trade1.Sell_Currency__c = 'EUR';
        trade1.BypassFlow__c = true;
        trades.add(trade1);

        Trade__c trade2 = new Trade__c();
        trade2.Buy_Currency__c = 'EUR';
        trade2.Date_Booked__c = Datetime.now();
        trade2.Rate__c = 0.98;
        trade2.Sell_Amount__c = 100;
        trade2.BypassFlow__c = true;
        trade2.Sell_Currency__c = 'USD';
        trades.add(trade2);
        
        insert trades;
    }

    @isTest
    public static void test_getTrades() {
        Test.startTest();
        List<Trade__c> trades = MainTradeHelper.getTrades();
        Test.stopTest();
        System.assertEquals(2, trades.size());
    }

    @isTest
    public static void test_getGlobalPicklist(){
        Test.startTest();
        List<String> picklist = MainTradeHelper.getGlobalPicklist();
        Test.stopTest();
        System.assert(picklist.size()>0);
        System.assert(picklist.contains('USD'));
    }

    @isTest
    public static void test_createTrade(){
        Test.startTest();
        String response = MainTradeHelper.createTrade('USD', 'EUR', '100', '1.1');
        String response2 = MainTradeHelper.createTrade('EUR', 'USD', '-1', '0.98');
        String response3 = MainTradeHelper.createTrade('EUR', 'USD', '1', '-0.98');
        Test.stopTest();
        System.assertEquals('Success', response);
        System.assert(response2.contains('Error'));
        System.assert(response3.contains('Error'));
    }


    @IsTest 
    private static void testApexSimpleContinuationPassingDataForLWC() {
        String mockResponseBody = '{"rates": {"USD": 1.1, "EUR": 0.98}}';

        Test.startTest();
        Continuation con = (Continuation) MainTradeHelper.rateRequest('EUR','USD');
        Test.stopTest();
        
        // Verify that the continuation has the correct number of requests
        Map<String, HttpRequest> requests = con.getRequests();
        System.assertEquals(1, requests.size(), 'The number of requests associated to the Continuation is not correct');

        // Create a mock response
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody(mockResponseBody);

        Test.setContinuationResponse(MainTradeHelper.contState, response);

        List<String> labels = new List<String>{MainTradeHelper.contState};

        String result = JSON.serialize(MainTradeHelper.rateResponse(labels,MainTradeHelper.contlabel));

        system.debug(result);
        
        System.assert(result.contains('"EUR":0.98'), 'Continuation failed: response body not valid');
        System.assert(result.contains('"USD":1.1'), 'Continuation failed: response body not valid');
    }
}