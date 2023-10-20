@isTest
public class OpportunityTriggerHandlerTest {
    private static boolean recordsCreated = false;
    private static User testUser;
    private static Opportunity testOpportunity;
    private static UserRole salesRole;

    static void testSetup() {
        List<UserRole> existingSalesRole = [SELECT Id FROM UserRole WHERE Name = 'Sales Role' LIMIT 1];

        if (existingSalesRoles.isEmpty()) {
            salesRole = new UserRole(Name = 'Sales Role');
            insert salesRole;
        } else {
            salesRole = existingSalesRoles[0];
        }

        testUser = new User(
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

        testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today(),
            StageName = 'Needs Analysis',
            OwnerId = testUser.Id
        );
        System.RunAs(testUser) { 
            insert testOpportunity;
        }
        recordsCreated = true;
    }

    @isTest
    static void testIncrementDealsWonCounter() {
        if (!recordsCreated) {
            createTestRecords();
        }

        Test.startTest();
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;
        Test.stopTest();

        User updatedUser = [SELECT Deals_Won__c FROM User WHERE Id = :testUser.Id];
        System.assertEquals(1, updatedUser.Deals_Won__c, 'Deals_Won__c should be incremented to 1');
    }

}