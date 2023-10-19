@isTest
public class OpportunityTriggerHandlerTest {
    @isTest
    static void incrementDealsWonCounterTest() {

        UserRole salesRole = new UserRole(Name = 'Sales Role');
        insert salesRole;
        
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
        
        Test.startTest();
        OpportunityTriggerHandler.incrementDealsWonCounter(new List<Opportunity>{testOpportunity}, null);
        Test.stopTest();
        
        User updatedUser = [SELECT Deals_Won__c FROM User WHERE Id = :testUser.Id];
        System.assertEquals(1, updatedUser.Deals_Won__c, 'Deals_Won__c should be incremented to 1');
    }
}
