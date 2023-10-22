public with sharing class HandleOppsScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Date today = Date.today();
        
        opportunitiesToUpdate = [SELECT Id FROM Opportunity WHERE CloseDate = :today AND IsWon = false];
        for (Opportunity opp : opportunitiesToUpdate) {
            opp.StageName = 'Closed Lost';
        }
        
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }
}
