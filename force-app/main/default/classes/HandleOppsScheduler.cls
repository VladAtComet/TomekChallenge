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
                Integer batchSize = 200;
                List<List<Opportunity>> oppBatches = createBatches(opportunitiesToUpdate, batchSize);
    
                for (List<Opportunity> batch : oppBatches) {
                    updateOpportunityBatch(batch);
                }
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
    
    private static List<List<Opportunity>> createBatches(List<Opportunity> opportunities, Integer batchSize) {
        List<List<Opportunity>> oppBatches = new List<List<Opportunity>>();
        for (Integer i = 0; i < opportunities.size(); i += batchSize) {
            List<Opportunity> batch = new List<Opportunity>();
            for (Integer j = 0; j < Math.min(batchSize, opportunities.size() - i); j++) {
                batch.add(opportunities[i + j]);
            }
            oppBatches.add(batch);
        }
        return oppBatches;
        
    }
    
    
    private static void updateOpportunityBatch(List<Opportunity> batch) {
        update batch;
    }
// Helper Methods end
}
