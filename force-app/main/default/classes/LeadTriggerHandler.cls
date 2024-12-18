/*
 * The `LeadTriggerHandler` class contains methods designed to handle various business requirements around
 * the Lead object in Salesforce. This includes functionality like normalizing the title field of a lead, 
 * automatically scoring leads based on certain criteria, and auto-converting leads when certain conditions are met.
 * - Create a test class for `LeadTriggerHandler` to ensure all methods work as expected.
 * - Update the LeadTrigger class to call the `LeadTriggerHandler` methods as needed.
 *
 * Students should note:
 * - This class may contain intentional errors that need to be fixed for proper functionality.
 * - Create a corresponding test class for `LeadTriggerHandler` to ensure all methods work as expected.
 *   Both positive and negative test cases should be considered.
 *
 * Documentation on Lead conversion and Test Classes can be found here:
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_dml_convertLead.htm
 * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_test.htm
 */
public with sharing class LeadTriggerHandler {
	/* 
	 * Question 1
	 * Requirement Lead Title Normalization - handleTitleNormalization
	 * Occasionally, users input titles in a variety of ways. Streamline these titles for consistency:
	 *
	 * Criteria:
	 * - If the title contains terms such as 'vp', 'v.p.', or 'vice president',
	 *   change the title to 'Vice President'.
	 * - If the title contains terms like 'mgr', 'manage', or 'head of department',
	 *   change the title to 'Manager'.
	 * - Should the title include words like 'exec', 'chief', or 'head',
	 *   change the title to 'Executive'.
	 * - If the title contains terms like 'assist', 'deputy', or 'jr',
	 *   change the title to 'Assistant'.
	 */
	public static void handleTitleNormalization(List<Lead> leadsToNormalize) {
		for (Lead ld : leadsToNormalize) {
			if (ld.title == null){
				continue;
			} else if (ld.title.containsIgnoreCase('vp') || ld.title.containsIgnoreCase('v.p.') || ld.title.containsIgnoreCase('vice president')) {
				ld.Title = 'Vice President';
			} else if (
				ld.title.containsIgnoreCase('mgr') ||
				ld.title.containsIgnoreCase('manage') ||
				ld.title.containsIgnoreCase('head of department')
			) {
				ld.Title = 'Manager';
			} else if (ld.title.containsIgnoreCase('exec') || ld.title.containsIgnoreCase('chief') || ld.title.containsIgnoreCase('head')) {
				ld.Title = 'Executive';
			} else if (ld.title.containsIgnoreCase('assist') || ld.title.containsIgnoreCase('deputy') || ld.title.containsIgnoreCase('jr')) {
				ld.Title = 'Assistant';
			}
		}
	}

	/* 
	 * Question 2
	 * Requirement Auto Lead Scoring - handleAutoLeadScoring
	 * Implement logic to automatically assign scores to leads based on specific criteria.
	 * 18 should be highest possible score a lead can have.
	 *
	 * Criteria:
	 * - If the lead source is from the website and an email exists, increment score by 3 points.
	 * - If the lead provides a phone number, increment score by 5 points.
	 * - If the lead belongs to the 'Technology' industry, increment score by another 10 points.
	 */
	public static void handleAutoLeadScoring(List<Lead> leadsToScore) {
		for (Lead ld : leadsToScore) {
			Integer score = 0;

			// Check and add points based on the specified conditions
			if (ld.LeadSource == 'Website' && ld.Email != null) {
				score += 3;
			}

			if (ld.Phone != null) {
				score += 5;
			}

			if (ld.Industry == 'Technology') {
				score += 10;
			}

			if (score > 18) {
				score = 18;
			}

			ld.Lead_Score__c = score; // Set the computed score back to the lead
		}
	}

	/* 
	 * Question 3
	 * Requirement Automatic Lead Conversion Based on Email Match - handleLeadAutoConvert
	 * Whenever a new Lead is created or an existing Lead's email address is updated,
	 * check for a matching Contact based on the email address. If a single matching
	 * Contact is identified, auto-convert the Lead.
	 * Use the Salesforce report Converted Lead to verify that the Lead was converted to the correct Contact.
	 *
	 * Criteria:
	 * - Monitor the "Email" field on the Lead object for creation or updates.
	 * - On Lead creation or email update, search the Contact object for records with the
	 *   same email address.
	 * - If a single matching Contact is identified:
	 *     - Auto-convert the Lead.
	 *     - Merge the Lead details with the existing Contact, ensuring that crucial
	 *       Contact information is preserved.
	 * - If multiple Contacts with the same email are found or no match is identified,
	 *   leave the Lead unconverted.
	 */
	public static void handleLeadAutoConvertOnInsert(List<Lead> leads) {
		// Create a list to hold the Leads that should be check for the autoconvert
		List<Lead> leadsWithEmailUpdate = new List<Lead>();

		// For each Lead, only send to the autoconvert method if Email is not null
		for (Lead newLead : leads) {
			if (newLead.Email != null) {
				leadsWithEmailUpdate.add(newLead);
			}
		}
		LeadUtils.autoConvertLeads(leadsWithEmailUpdate);
	}

	public static void handleLeadAutoConvertOnUpdate(List<Lead> updatedleads, List<Lead> oldLeads) {
		// Create a list to hold the Leads that should be check for the autoconvert
		List<Lead> leadsWithEmailUpdate = new List<Lead>();
		// Create a map to match the Lead Id's wih their old Email values
		Map<Id,String> oldLeadToEmailMap = new Map<Id,String>();

		// For each Lead, add them to a map with old Email values
		for (Lead oldLead : oldLeads) {
			oldLeadToEmailMap.put(oldLead.Id, oldLead.Email);
		}

		// For each Lead, if the Email is not the same as the old value, add the Lead to list to update
		for (Lead newLead : updatedleads) {
			if ((newLead.Email == null || newLead.Email != oldLeadToEmailMap.get(newLead.Id)) && !newLead.IsConverted) {
				leadsWithEmailUpdate.add(newLead);
			}
		}

		//If there is at least 1 Lead to convert, call the method and pass it the leads to autoconvert
		if(!leadsWithEmailUpdate.isEmpty()) {
			LeadUtils.autoConvertLeads(leadsWithEmailUpdate);
		}
	}
}