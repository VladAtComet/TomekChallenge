public with sharing class ResetDealCountersScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        
        List<User> usersToReset = queryAllSalesUsers();

        for (User user : usersToReset) {
            if (Schema.sObjectType.User.isUpdateable()) {
                user.Deals_Won__c = 0;
                user.Deals_Lost__c = 0;
            }
        }

        update usersToReset;
    }

    private static List<User> queryAllSalesUsers() {
        return [
            SELECT Id, Name, UserRole.Name, Deals_Won__c, Deals_Lost__c
            FROM User
            WHERE UserRole.Name LIKE '%Sales%'
            AND (Deals_Won__c != 0 OR Deals_Lost__c != 0)
            WITH SECURITY_ENFORCED
        ];
    }
}
