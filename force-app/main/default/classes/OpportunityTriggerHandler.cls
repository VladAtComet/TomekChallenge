/*  Your default should be "public with sharing class XYZ"
    Empty, "with inherited sharing", "without sharing" only if you know what you're doing.
    And ideally with a good explanation why. PMD complains about it too
*/
public class OpportunityTriggerHandler {
    
    public static void handleBeforeInsert(List<Opportunity> triggerNew) {
    }
    
    public static void handleAfterInsert(List<Opportunity> triggerNew) {
    }
    
    public static void handleBeforeUpdate(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap) {
    }
    
    public static void handleAfterUpdate(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        incrementDealsWonCounter(triggerNew, triggerOldMap);
    }

    /* Good choice for "side effect", should be an after update.
    */
    public static void incrementDealsWonCounter(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Set<Id> userIdsToUpdate = new Set<Id>();
        
        for (Opportunity opp : triggerNew) {
/*  This is exactly the trap I laid in the interview. 
    This code will happily count each time a closed won oppty gets updated. You should detect the change of the picklist, not just current status.

    Or even better - opportunities can have multiple statuses that mean Closed Won.
    Go check the Picklist values on Opportunity.StageName in your org, there's this Probability field
    You can have multiple statuses that count as lost or won (for reporting for example  difference between "we suck", "competitor deal was better", "client pulled out of the deal")
    So a "pro" consultant would take the poorly written requirement from the client and transform it a bit into checking the hidden checkboxes on Opportunity:
    IsWon, IsClosed.
    This takes a bit of experience tho.
*/
            if (opp.StageName == 'Closed Won') {
                userIdsToUpdate.add(opp.OwnerId);
            }
        }
    
        // PMD complains about security, right? read up about "WITH USER_MODE"
        List<User> salesUsers = [SELECT Id, Deals_Won__c FROM User WHERE UserRole.Name LIKE '%Sales%' AND Id IN :userIdsToUpdate];
    
        for (User user : salesUsers) {
            if (user.Deals_Won__c == null) {
                user.Deals_Won__c = 1;
            } else {
                user.Deals_Won__c += 1;
            }
        }
        /*  This won't count right. If I mass close win 7 opportunities you'll give me just +1?
            Could use some Map<Id, Integer>. I think you had it in old version before merge?
        */
    
        update salesUsers;

        // Deals Lost is still TODO?
    }
    
}