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

    public static void incrementDealsWonCounter(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Set<Id> userIdsToUpdate = new Set<Id>();
        
        for (Opportunity opp : triggerNew) {
            if (opp.StageName == 'Closed Won') {
                userIdsToUpdate.add(opp.OwnerId);
            }
        }
    
        List<User> salesUsers = [SELECT Id, Deals_Won__c FROM User WHERE UserRole.Name LIKE '%Sales%' AND Id IN :userIdsToUpdate];
    
        for (User user : salesUsers) {
            if (user.Deals_Won__c == null) {
                user.Deals_Won__c = 1;
            } else {
                user.Deals_Won__c += 1;
            }
        }
    
        update salesUsers;
    }
    
}