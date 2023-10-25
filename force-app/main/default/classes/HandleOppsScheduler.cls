public with sharing class HandleOppsScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        scheduleOpportunityUpdates();
    }

    public static void scheduleOpportunityUpdates() {
        try {
            List<Opportunity> allActiveOpportunitiesToday = queryAllActiveOpportunitiesToday();
            List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

            for (Opportunity opp : allActiveOpportunitiesToday) {
                if (Schema.sObjectType.Opportunity.isUpdateable()) {
                    opp.StageName = 'Closed Lost';
                    opportunitiesToUpdate.add(opp);
                }
            }

            if (!opportunitiesToUpdate.isEmpty()) {
                updateOpportunities(opportunitiesToUpdate);
            }
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }
    }

    // Helper Methods
    private static List<Opportunity> queryAllActiveOpportunitiesToday() {
        Date today = Date.today();
        return [SELECT Id FROM Opportunity WHERE CloseDate = :today AND IsWon = false WITH SECURITY_ENFORCED];
    }

    private static void updateOpportunities(List<Opportunity> opportunitiesToUpdate) {
        if (!opportunitiesToUpdate.isEmpty()) {
            // Perform bulk update
            Database.update(opportunitiesToUpdate, false);
        }
    }
    // Helper Methods end
}
