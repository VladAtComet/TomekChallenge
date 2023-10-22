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
        increaseDealsLostCounterIfOpportunityIsLost(triggerNew, triggerOldMap);
        decreaseDealsLostCounterIfALostOpportunityChangesStage(triggerNew, triggerOldMap);
        
    }

// Methods for task 1
    public static void increaseDealsWonCounterIfOpportunityIsWon(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = findWonOpportunities(triggerNew, triggerOldMap);
    
        if (!updatedOpportunitiesMap.isEmpty()) {
            List<User> allSalesUsers = querySalesUsersDealsWon(updatedOpportunitiesMap.keySet());
    
            updateDealsWonCount(allSalesUsers, updatedOpportunitiesMap, true);
        }
    }

    public static void decreaseDealsWonCounterIfAWonOpportunityChangesStage(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = findFormallyWonOpportunities(triggerNew, triggerOldMap);
    
        if (!updatedOpportunitiesMap.isEmpty()) {
            List<User> allSalesUsers = querySalesUsersDealsWon(updatedOpportunitiesMap.keySet());
    
            updateDealsWonCount(allSalesUsers, updatedOpportunitiesMap, false);
        }
    }
// Methods for task 1 end

// Helper methods for task 1
    private static Map<Id, Integer> findWonOpportunities(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = new Map<Id, Integer>();

        for (Opportunity opp : triggerNew) {
            if (isOpportunityWon(opp) && !wasOpportunityWon(opp, triggerOldMap)) {
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

    private static Map<Id, Integer> findFormallyWonOpportunities(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = new Map<Id, Integer>();

        for (Opportunity opp : triggerNew) {
            if (!isOpportunityWon(opp) && wasOpportunityWon(opp, triggerOldMap)) {
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

    private static List<User> querySalesUsersDealsWon(Set<Id> userIDs) {
        return [SELECT Id, Deals_Won__c FROM User WHERE UserRole.Name LIKE '%Sales%' AND Id IN :userIDs WITH SECURITY_ENFORCED];
    }

    private static void updateDealsWonCount(List<User> salesUsers, Map<Id, Integer> updatedOpportunitiesMap, boolean boolIncrease) {
        for (User user : salesUsers) {
            Integer opportunitiesToUpdate = updatedOpportunitiesMap.get(user.Id);
            if (opportunitiesToUpdate != null) {
                user.Deals_Won__c = boolIncrease
                    ? (user.Deals_Won__c != null ? user.Deals_Won__c + opportunitiesToUpdate : opportunitiesToUpdate)
                    : (user.Deals_Won__c != null ? user.Deals_Won__c - opportunitiesToUpdate : opportunitiesToUpdate - 1);
            }
        }
        update salesUsers;
    }
// Helper methods for task 1 end

// Methods for task 2
    public static void increaseDealsLostCounterIfOpportunityIsLost(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = findLostOpportunities(triggerNew, triggerOldMap);

        if (!updatedOpportunitiesMap.isEmpty()) {
            List<User> allSalesUsers = querySalesUsersDealsLost(updatedOpportunitiesMap.keySet());

            updateDealsLostCount(allSalesUsers, updatedOpportunitiesMap, true);
        }
    }

    public static void decreaseDealsLostCounterIfALostOpportunityChangesStage(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = findFormallyLostOpportunities(triggerNew, triggerOldMap);

        if (!updatedOpportunitiesMap.isEmpty()) {
            List<User> allSalesUsers = querySalesUsersDealsLost(updatedOpportunitiesMap.keySet());

            updateDealsLostCount(allSalesUsers, updatedOpportunitiesMap, false);
        }
    }
// Methods for task 2 end

// Helper methods for task 2
    private static Map<Id, Integer> findLostOpportunities(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = new Map<Id, Integer>();

        for (Opportunity opp : triggerNew) {
            if (isOpportunityLost(opp) && !wasOpportunityLost(opp, triggerOldMap)) {
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

    private static Map<Id, Integer> findFormallyLostOpportunities(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
        Map<Id, Integer> updatedOpportunitiesMap = new Map<Id, Integer>();

        for (Opportunity opp : triggerNew) {
            if (!isOpportunityLost(opp) && wasOpportunityLost(opp, triggerOldMap)) {
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

    private static boolean wasOpportunityLost(Opportunity opp, Map<Id, Opportunity> triggerOldMap) {
        return triggerOldMap.get(opp.Id).StageName == 'Closed Lost';
    }

    private static boolean isOpportunityLost(Opportunity opp) {
        return opp.StageName == 'Closed Lost';
    }

    private static List<User> querySalesUsersDealsLost(Set<Id> userIDs) {
        return [SELECT Id, Deals_Lost__c FROM User WHERE UserRole.Name LIKE '%Sales%' AND Id IN :userIDs WITH SECURITY_ENFORCED];
    }

    private static void updateDealsLostCount(List<User> salesUsers, Map<Id, Integer> updatedOpportunitiesMap, boolean boolDecrease) {
        for (User user : salesUsers) {
            Integer opportunitiesToUpdate = updatedOpportunitiesMap.get(user.Id);
            if (opportunitiesToUpdate != null) {
                user.Deals_Lost__c = boolDecrease
                    ? (user.Deals_Lost__c != null ? user.Deals_Lost__c - opportunitiesToUpdate : -opportunitiesToUpdate)
                    : (user.Deals_Lost__c != null ? user.Deals_Lost__c + opportunitiesToUpdate : opportunitiesToUpdate + 1);
            }
        }
        update salesUsers;
    }
// Helper methods for task 2 end

}