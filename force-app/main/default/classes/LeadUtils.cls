/*
* This Class contains methods to update Leads. These methods will be called from the LeadTriggerHandler class
* to provide functionality that would otherwise need to be written in multiple places
*/



/*

I am thinking that I will need to break the given function into 2, one for insert and one for update
The insert will just call a method from the utils class to perform the check and do the conversion if needed.
The update will need to be passed the trigger.old variable as well as the trigger.new. It will need to check if the
email address has changed. If so, it will add the lead to a new list that will be passed to the method in the utils 
class to perform the check and do conversion if needed. --- This part is completed!

The utils method will need to do a query and check that the size of the returned list is exactly 1. If it is larger 
than 1 or equal to zero, it will exit the loop. Otherwise, autoconvert the lead and merge details onto the lead? or
the existing contact?

I will need to have 2 tests. The insert one will need to look for contacts with the email address before the insert 
is even done. And if the email matches 1 contact, add that email to a list. And then query the contacts for that
email after the insert and make sure equals 2? Not sure if that would work. But then all the ones that were updated
will need to have the description updated? I am super confused about this one... I will also have to do an update step
which will have to be after the insert checks.

*/

public with sharing class LeadUtils {
    /*
    * The autoConvertLeads function checks if a lead should be autoconverted, and if so, handles the operation.
    */
    public static void autoConvertLeads(List<Lead> leads) {
        // Step 1: Gather all lead emails
        Map<Id,String> leadToEmailMap = new Map<Id,String>();
		for (Lead lead : leads) {
			leadToEmailMap.put(lead.Id, lead.Email);
		}

		// Step 2: Find matching contacts based on email
		Map<String, Contact> emailToContactMap = new Map<String, Contact>();
		for (Contact c : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :leadToEmailMap.values()]) {
			if (!emailToContactMap.containsKey(c.Email)) {
				emailToContactMap.put(c.Email, c);
			} else {
				// If we found another contact with the same email, we don't auto-convert.
				// So we remove the email from the map.
				leadToEmailMap.remove(c.Email);
			}
		}

		// Step 3: Auto-convert leads
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
		for (Id leadId : leadToEmailMap.keySet()) {
            String leadEmail = leadToEmailMap.get(leadId);
			if (emailToContactMap.containsKey(leadEmail)) {
				Database.LeadConvert lc = new Database.LeadConvert();
				lc.setLeadId(leadId);
				lc.setContactId(emailToContactMap.get(leadEmail).Id); // Use existing Contact Id
				lc.setAccountId(emailToContactMap.get(leadEmail).AccountId); // Use existing Account Id
				lc.setDoNotCreateOpportunity(true); // Assuming we don't want to create an opportunity
				lc.setConvertedStatus(convertStatus.MasterLabel); // Set the converted status
				leadConverts.add(lc);
			}
		}

		if (!leadConverts.isEmpty()) {
			List<Database.LeadConvertResult> lcrs = Database.convertLead(leadConverts);
		}
    }
}