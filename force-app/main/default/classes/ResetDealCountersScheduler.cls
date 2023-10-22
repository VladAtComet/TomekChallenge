public with sharing class ResetDealCountersScheduler implements Schedulable {
    public void execute(SchedulableContext context) {

            List<User> usersToReset = [
                SELECT Id, Name, UserRole.Name, Deals_Won__c, Deals_Lost__c
                FROM User
                WHERE UserRole.Name LIKE '%Sales%'
                AND (Deals_Won__c != 0 OR Deals_Lost__c != 0)
            ];

            for (User user : usersToReset) {
                user.Deals_Won__c = 0;
                user.Deals_Lost__c = 0;
            }
    
            update usersToReset;
    }
}
