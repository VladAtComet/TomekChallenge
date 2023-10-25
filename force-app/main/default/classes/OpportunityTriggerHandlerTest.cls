@isTest
public class OpportunityTriggerHandlerTest {
    private static User testUser;
    private static Opportunity testOpportunity;
    private static Opportunity testOpportunity2;
    private static UserRole salesRole;

    @testSetup
    static void testSetup() {
        List<UserRole> existingSalesRole = [SELECT Id FROM UserRole WHERE Name = 'Sales Role' LIMIT 1];

        if (existingSalesRole.isEmpty()) {
            salesRole = new UserRole(Name = 'Sales Role');
            insert salesRole;
        } else {
            salesRole = existingSalesRole[0];
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
        System.RunAs(testuser) {
            insert testOpportunity;
        }
    
        testOpportunity2 = new Opportunity(
            Name = 'Test Opportunity2',
            CloseDate = Date.today(),
            StageName = 'Needs Analysis',
            OwnerId = testUser.Id
        );
        System.RunAs(testUser) {
            insert testOpportunity2;
        }
    }
// Tests for task 1
    @isTest
    static void testIncreaseDealsWonCounter() {
        testOpportunity = [SELECT ID FROM Opportunity LIMIT 1];

        Test.startTest();
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;
        Test.stopTest();

        testUser = [SELECT Deals_Won__c FROM User WHERE Email = 'testuser@example.com'];
        System.assertEquals(1, testUser.Deals_Won__c, 'Deals_Won__c should be incremented to 1');
    }

    @isTest
    static void testUpdateOpportunityFieldOtherThanStageWon() {

        testOpportunity = [SELECT ID FROM Opportunity LIMIT 1];

        Test.startTest();
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;
        testOpportunity.Name = 'new';
        update testOpportunity;
        Test.stopTest();

        testUser = [SELECT Deals_Won__c FROM User WHERE Email = 'testuser@example.com'];
        System.assertEquals(1, testUser.Deals_Won__c, 'Deals_Won__c should be 1');
    }

    @isTest
    static void testUpdate2OrMoreOppsToClosedWon() {
        List<Opportunity> testOpportunities = [SELECT ID FROM Opportunity LIMIT 2];
    
        System.assertEquals(2, testOpportunities.size(), 'There should be at least two Opportunities');
    
        for (Opportunity opp : testOpportunities) {
            opp.StageName = 'Closed Won';
        }
    
        Test.startTest();
        update testOpportunities;
        Test.stopTest();
    
        testUser = [SELECT Deals_Won__c FROM User WHERE Email = 'testuser@example.com'];

        System.assertEquals(2, testUser.Deals_Won__c, 'Deals_Won__c should be 2');
    }
    
    @isTest
    static void testDecreaseDealsWonCounter() {
        Opportunity testOpportunity = [SELECT ID FROM Opportunity LIMIT 1];
    
        Test.startTest();
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;
        testOpportunity.StageName = 'Needs Analysis';
        update testOpportunity;
        Test.stopTest();

        testUser = [SELECT Deals_Won__c FROM User WHERE Email = 'testuser@example.com'];
    
        System.assertEquals(0, testUser.Deals_Won__c, 'Deals_Won__c should be 0');
    }
// Tests for task 1 end

// Tests for task 2
    @isTest
    static void testIncreaseDealsLostCounter() {
        testOpportunity = [SELECT ID FROM Opportunity LIMIT 1];

        Test.startTest();
        testOpportunity.StageName = 'Closed Lost';
        update testOpportunity;
        Test.stopTest();

        testUser = [SELECT Deals_Lost__c FROM User WHERE Email = 'testuser@example.com'];
        System.assertEquals(-1, testUser.Deals_Lost__c, 'Deals_Lost__c should be incremented to -1');
    }

    @isTest
    static void testUpdateOpportunityFieldOtherThanStageLost() {

        testOpportunity = [SELECT ID FROM Opportunity LIMIT 1];

        Test.startTest();
        testOpportunity.StageName = 'Closed Lost';
        update testOpportunity;
        testOpportunity.Name = 'new';
        update testOpportunity;
        Test.stopTest();

        testUser = [SELECT Deals_Lost__c FROM User WHERE Email = 'testuser@example.com'];
        System.assertEquals(-1, testUser.Deals_Lost__c, 'Deals_Lost__c should be 1');
    }

    @isTest
    static void testUpdate2OrMoreOppsToClosedLost() {
        List<Opportunity> testOpportunities = [SELECT ID FROM Opportunity LIMIT 2];
    
        System.assertEquals(2, testOpportunities.size(), 'There should be at least two Opportunities');
    
        for (Opportunity opp : testOpportunities) {
            opp.StageName = 'Closed Lost';
        }
    
        Test.startTest();
        update testOpportunities;
        Test.stopTest();
    
        testUser = [SELECT Deals_Lost__c FROM User WHERE Email = 'testuser@example.com'];

        System.assertEquals(-2, testUser.Deals_Lost__c, 'Deals_Lost__c should be -2');
    }

    @isTest
    static void testDecreaseDealsLostCounter() {
        Opportunity testOpportunity = [SELECT ID FROM Opportunity LIMIT 1];
    
        Test.startTest();
        testOpportunity.StageName = 'Closed Lost';
        update testOpportunity;
        testOpportunity.StageName = 'Needs Analysis';
        update testOpportunity;
        Test.stopTest();

        testUser = [SELECT Deals_Lost__c FROM User WHERE Email = 'testuser@example.com'];
    
        System.assertEquals(0, testUser.Deals_Lost__c, 'Deals_Lost__c should be 0');
    }
// Tests for task 2 end

}