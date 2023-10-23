public with sharing class HandleOppsScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        
        List<Opportunity> allActiveOpportunitiesToday = queryAllActiveOpportunitiesToday();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        for (Opportunity opp : opportunitiesToUpdate) {
            opp.StageName = 'Closed Lost';
            opportunitiesToUpdate.add(opp);
        }
        
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }
    
    private static List<Opportunity> queryAllActiveOpportunitiesToday() {
        Date today = Date.today();
        return [SELECT Id FROM Opportunity WHERE CloseDate = :today AND IsWon = false WITH SECURITY_ENFORCED];
    }
}
