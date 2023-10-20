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
        Map<Id, Integer> userOpportunityCount = countUserOpportunities(triggerNew, triggerOldMap);
    
        if (!userOpportunityCount.isEmpty()) {
            List<User> allSalesUsers = querySalesUsers(userOpportunityCount.keySet());
    
            updateUsersWithOpportunityCount(allSalesUsers, userOpportunityCount);
        }
    }
// incrementDealsWonCounter() helper methods 
    private static Map<Id, Integer> countUserOpportunities(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> userOpportunityCount = new Map<Id, Integer>();
    
        for (Opportunity opp : triggerNew) {
            if (isOpportunityWon()) {
                Id oppOwnerId = opp.OwnerId;
                if (!userOpportunityCount.containsKey(oppOwnerId)) {
                    userOpportunityCount.put(oppOwnerId, 1);
                } else {
                    userOpportunityCount.put(oppOwnerId, userOpportunityCount.get(oppOwnerId) + 1);
                }
            }
        }
    
        return userOpportunityCount;
    }

    private static boolean isOpportunityWon(Opportunity opp, Map<Id, Opportunity> triggerOldMap) {
        return opp.StageName != triggerOldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won';
    }
    
    private static List<User> querySalesUsers(Set<Id> userIDs) {
        return [SELECT Id, Deals_Won__c FROM User WHERE UserRole.Name LIKE '%Sales%' AND Id IN :userIDs WITH SECURITY_ENFORCED];
    }
    
    private static void updateUsersWithOpportunityCount(List<User> salesUsers, Map<Id, Integer> opportunityCountMap) {
        for (User user : salesUsers) {
            user.Deals_Won__c = user.Deals_Won__c != null ? user.Deals_Won__c + opportunityCountMap.get(user.Id) : opportunityCountMap.get(user.Id);
        }
    
        update salesUsers;
    }
// incrementDealsWonCounter() helper methods  
}