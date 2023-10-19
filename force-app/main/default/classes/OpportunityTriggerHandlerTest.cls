@isTest
public class OpportunityTriggerHandlerTest {
    // Next time you create tests read about @testSetup method. Quite useful for inserting all reference data for your test just once if you have multiple test methods

    @isTest
    static void incrementDealsWonCounterTest() { // it's a bit of convention to write the methods with "test" word first. "testHappyFlow", "testErrorScenarios" etc.

        UserRole salesRole = new UserRole(Name = 'Sales Role');
        insert salesRole;// I wonder what happens when you already have a role like that in the org. Does it explode on unique name?
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            CommunityNickname = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserRoleId = salesRole.Id
        );
        insert testUser;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today(),
            StageName = 'Closed Won',
            OwnerId = testUser.Id
        );

        System.RunAs(testUser) { 
            insert testOpportunity;
        }
        
        /*  This is not ok.
            You aren't testing the real scenario. You're cheating by calling the method yourself.
            Bit more "pro" would be to insert the opportunity in stage Open or whatever and then have

                Test.startTest();
                testOpportunity.StageName = 'Closed Won';
                update testOpportunity;
                Test.stopTest();

            That way is closer to real user clicking Save or whatever. And it'll actually run the trigger & afterUpdate...
            I mean... write the test like a black box. Nobody cares whether the logic is implemented as trigger, workflow, flow, process builder.
            I close an opp, I expect +1, by any means neccessary.
        */

        Test.startTest();
        OpportunityTriggerHandler.incrementDealsWonCounter(new List<Opportunity>{testOpportunity}, null);
        Test.stopTest();
        
        User updatedUser = [SELECT Deals_Won__c FROM User WHERE Id = :testUser.Id];
        System.assertEquals(1, updatedUser.Deals_Won__c, 'Deals_Won__c should be incremented to 1');
    }

    /* 
        Write a test that checks if i'm right about that "opp.StageName == 'Closed Won'"
        If I spam
        OpportunityTriggerHandler.incrementDealsWonCounter(new List<Opportunity>{testOpportunity}, null);
        OpportunityTriggerHandler.incrementDealsWonCounter(new List<Opportunity>{testOpportunity}, null);
        OpportunityTriggerHandler.incrementDealsWonCounter(new List<Opportunity>{testOpportunity}, null);
        OpportunityTriggerHandler.incrementDealsWonCounter(new List<Opportunity>{testOpportunity}, null);

        will I get +4?
        Write test that expects just +1, see it crash, keep fixing the triggerhandler until it passes.
    */
}
