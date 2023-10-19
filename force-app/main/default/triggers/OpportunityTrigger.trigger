trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
/*  Next time consider a trigger handler, the less logic you have the better. even this "ladder" or ifs it annoying to copypaste over and over
    Hupans suck at copy paste search replace ;)
    PMD highlights as "avoid logic in triggers, right?
    plus there's a switch statement that makes it look minimally better:

    https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_context_variables.htm
    https://developer.salesforce.com/docs/atlas.en-us.246.0.apexref.meta/apexref/apex_enum_System_TriggerOperation.htm
*/
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