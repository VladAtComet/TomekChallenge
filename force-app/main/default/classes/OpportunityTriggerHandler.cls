public class OpportunityTriggerHandler {
    
    public static void handleBeforeInsert(List<Opportunity> triggerNew) {
    }
    
    public static void handleAfterInsert(List<Opportunity> triggerNew) {
    }
    
    public static void handleBeforeUpdate(List<Opportunity> triggerNew, Map<Id,Opportunity> triggerOldMap) {
    }
    
    public static void handleAfterUpdate(List<Opportunity> triggerNew, Map<Id, Opportunity> triggerOldMap) {
    // Create a map to store the number of won deals for each user
    Map<Id, Integer> userIdToDealsWon = new Map<Id, Integer>();
    
    for (Opportunity opp : triggerNew) {
        // Check if the opportunity's stage is 'Closed Won'
        if (opp.StageName == 'Closed Won') 
        
        {
            // Increment the user's deal count in the map
            if (userIdToDealsWon.containsKey(opp.OwnerId)) {
                userIdToDealsWon.put(opp.OwnerId, userIdToDealsWon.get(opp.OwnerId) + 1);
            } else {
                userIdToDealsWon.put(opp.OwnerId, 1);
            }
        }
    }
    
    // Query the users whose role is 'Sales' and need to be updated
    List<User> salesUsers = [SELECT Id, Deals_Won__c FROM User WHERE UserRole.Name = 'Sales' AND Id IN :userIdToDealsWon.keySet()];
    
    // Update the Deals_Won__c field for the relevant users
    for (User user : salesUsers) {
        Integer dealsWon = userIdToDealsWon.get(user.Id);
        if (dealsWon != null) {
            user.Deals_Won__c += dealsWon;
        }
    }
    
        // Update the User records
        update salesUsers;
    }
}