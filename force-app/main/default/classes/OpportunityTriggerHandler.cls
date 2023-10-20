public with sharing class OpportunityTriggerHandler {
    
    public static void handleBeforeInsert(List<Opportunity> triggerNew) {
    }
    
    public static void handleAfterInsert(List<Opportunity> triggerNew) {
    }
    
    public static void handleBeforeUpdate(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap) {
    }
    
    public static void handleAfterUpdate(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        increaseDealsWonCounterIfOpportunityIsWon(triggerNew, triggerOldMap);
        decreaseDealsWonCounterIfAWonOpportunityChangesStage(triggerNew, triggerOldMap);
    }

    public static void increaseDealsWonCounterIfOpportunityIsWon(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = findUpdatedOpportunities(triggerNew, triggerOldMap);
    
        if (!updatedOpportunitiesMap.isEmpty()) {
            List<User> allSalesUsers = querySalesUsers(updatedOpportunitiesMap.keySet());
    
            updateDealsWonCount(allSalesUsers, updatedOpportunitiesMap, true);
        }
    }

    public static void decreaseDealsWonCounterIfAWonOpportunityChangesStage(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = findUpdatedOpportunities(triggerNew, triggerOldMap);
    
        if (!updatedOpportunitiesMap.isEmpty()) {
            List<User> allSalesUsers = querySalesUsers(updatedOpportunitiesMap.keySet());
    
            updateDealsWonCount(allSalesUsers, updatedOpportunitiesMap, false);
        }
    }

// General helper methods
    private static Map<Id, Integer> findUpdatedOpportunities(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = new Map<Id, Integer>();

        for (Opportunity opp : triggerNew) {
            if (isOpportunityWon(opp) != wasOpportunityWon(opp, triggerOldMap)) {
                Id oppOwnerId = opp.OwnerId;
                if (!updatedOpportunitiesMap.containsKey(oppOwnerId)) {
                    updatedOpportunitiesMap.put(oppOwnerId, 1);
                } else {
                    updatedOpportunitiesMap.put(oppOwnerId, updatedOpportunitiesMap.get(oppOwnerId) + 1);
                }
            }
        }

        return updatedOpportunitiesMap;
    }

    private static boolean wasOpportunityWon(Opportunity opp, Map<Id, Opportunity> triggerOldMap) {
        return triggerOldMap.get(opp.Id).StageName == 'Closed Won';
    }

    private static boolean isOpportunityWon(Opportunity opp) {
        return opp.StageName == 'Closed Won';
    }

    private static List<User> querySalesUsers(Set<Id> userIDs) {
        return [SELECT Id, Deals_Won__c FROM User WHERE UserRole.Name LIKE '%Sales%' AND Id IN :userIDs WITH SECURITY_ENFORCED];
    }

    private static void updateDealsWonCount(List<User> salesUsers, Map<Id, Integer> updatedOpportunitiesMap, boolean boolIncrease) {
        for (User user : salesUsers) {
            Integer opportunitiesToUpdate = updatedOpportunitiesMap.get(user.Id);
            if (opportunitiesToUpdate != null) {
                user.Deals_Won__c = boolIncrease
                    ? (user.Deals_Won__c != null ? user.Deals_Won__c + opportunitiesToUpdate : opportunitiesToUpdate + 1)
                    : (user.Deals_Won__c != null ? user.Deals_Won__c - opportunitiesToUpdate : opportunitiesToUpdate - 1);
            }
        }
        update salesUsers;
    }
// General helper methods 

}