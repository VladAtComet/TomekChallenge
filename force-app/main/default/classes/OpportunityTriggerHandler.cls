public with sharing class OpportunityTriggerHandler {
    
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
        Map<Id, Integer> userOpportunityCount = new Map<Id, Integer>();
        
        for (Opportunity opp : triggerNew) {
            if (opp.StageName != triggerOldMap.get(opp.Id).StageName &&
                (opp.StageName == 'Closed Won' || opp.Probability == 100)) {
                Id oppOwnerId = opp.OwnerId;
                if (!userOpportunityCount.containsKey(ownerId)) {
                    userOpportunityCount.put(oppOwnerId, 1);
                } else {
                    userOpportunityCount.put(oppOwnerId, userOpportunityCount.get(oppOwnerId) + 1);
                }
            }
        }
        
        if (canQueryUsersAndRoles()) {
            List<User> allSalesUsers = [SELECT Id, Deals_Won__c FROM User WHERE UserRole.Name LIKE '%Sales%' AND Id IN :userOpportunityCount.keySet()];
            List<User> salesUsersToUpdate = new List<User>();

            for (User user : allSalesUsers) {
                if (user.Deals_Won__c == null) {
                    user.Deals_Won__c = userOpportunityCount.get(user.Id);
                } else {
                    user.Deals_Won__c += userOpportunityCount.get(user.Id);
                }
                salesUsersToUpdate.add(opp.OwnerId);
            }

            if (!salesUsersToUpdate.isEmpty()) {
                update salesUsersToUpdate;
            }

        } else catch {
            // Handle the case where you can't query users and roles
            System.debug('Permission issue: Unable to query users and roles.');
        }
    }

    private static Boolean canQueryUsersAndRoles() {
        // Implement your permission checks here, e.g., based on profile or permission sets
        // Return true if the user has permission, false otherwise
        return true; // Modify this based on your permission checks
    }
    
}