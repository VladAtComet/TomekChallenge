trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
    if (Trigger.isInsert) {
        if (Trigger.isBefore) {
            
            // Process before insert
            OpportunityTriggerHandler.handleBeforeInsert(Trigger.new);
            
        } else if (Trigger.isAfter) {
            
            // Process after insert
            OpportunityTriggerHandler.handleAfterInsert(Trigger.new);
            
        } else if(Trigger.IsUpdate) {
            if (Trigger.isBefore) {
                
                // Process before update
                OpportunityTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
                
            } else if (Trigger.isAfter) {
                
                // Process after update
                OpportunityTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
            }        
        }
    }
}