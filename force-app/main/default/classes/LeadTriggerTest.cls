/*
 * Test trigger functionality when Leads are created or updated. Three actions should happen in each case:
 * Lead Title should be normalized,
 * Lead Score should be calculated, 
 * If exactly 1 Contact exists which the Lead's email address, the Lead should be automatically converted
 * 
 */

@IsTest
public with sharing class LeadTriggerTest {

    @IsTest
    static void testHandleTitleNormalization() {
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

    	// Create new Leads and add them to a list
        List<Lead> newLeads = DataGenerator.leadGenerator();

    	// Insert the Leads
    	Test.startTest();
        insert newLeads;
        Test.stopTest();


     	// Query the new Leads to assess changes made
        List<Lead> createdLeads = [SELECT Id, LastName, Title FROM Lead];

    	// Ensure that the correct number of records were created
    	Assert.areEqual(newLeads.size(), createdLeads.size(), 'Incorrect number of created Leads.');
    
    	// Ensure that Title was correctly normalized for each record
        for (Integer i=0; i < newLeads.size(); i++) {
            // Check that if Title was null, it is still null
			if (newLeads[i].Title == null) {
                Assert.areEqual(null, createdLeads[i].Title, 'Lead was given a Title when Title should be null.');

			// Check update of Vice Presidents' Titles
			} else if (newLeads[i].Title.containsIgnoreCase('vp') || newLeads[i].Title.containsIgnoreCase('v.p.') || newLeads[i].Title.containsIgnoreCase('vice president')) {
				Assert.areEqual('Vice President', createdLeads[i].Title, 'Vice President\'s Title was not normalized correctly');

			// Check update of Managers' Titles
			} else if (newLeads[i].Title.containsIgnoreCase('mgr') || newLeads[i].Title.containsIgnoreCase('manage') || newLeads[i].Title.containsIgnoreCase('head of department')) {
				Assert.areEqual('Manager', createdLeads[i].Title, 'Manager\'s Title was not normalized correctly');

			// Check update of Executives' Titles
			} else if (newLeads[i].Title.containsIgnoreCase('exec') || newLeads[i].Title.containsIgnoreCase('chief') || newLeads[i].Title.containsIgnoreCase('head')) {
				Assert.areEqual('Executive', createdLeads[i].Title, 'Executive\'s Title was not normalized correctly');

			// Check update of Assistants' Titles
			} else if (newLeads[i].Title.containsIgnoreCase('assist') || newLeads[i].Title.containsIgnoreCase('deputy') || newLeads[i].Title.containsIgnoreCase('jr')) {
				Assert.areEqual('Assistant', createdLeads[i].Title, 'Assistant\'s Title was not normalized correctly');

			// Check that no other Leads had their Titles changed
			} else {
                Assert.areEqual(newLeads[i].Title, createdLeads[i].Title, 'Lead Title should be unchanged.');
            }
        }
    }

    @IsTest
    static void testHandleAutoLeadScoring() {
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

		// Create new Leads and add them to a list
		List<Lead> newLeads = DataGenerator.leadGenerator();

		// Insert the Leads
		Test.startTest();
		insert newLeads;
		Test.stopTest();

		// Query the new Leads to assess changes made
		List<Lead> createdLeads = [SELECT Id, FirstName, LastName, Lead_Score__c, Email, Phone, LeadSource, Industry FROM Lead];

		// Ensure that the correct number of records were created
		Assert.areEqual(newLeads.size(), createdLeads.size(), 'Incorrect number of created Leads.');

		// Calculate the correct score for each Lead
		for (Lead loopLead : createdLeads) {
			Integer leadScore = 0;
			if (loopLead.email != null && loopLead.LeadSource == 'Website') {
				leadScore += 3;
			}
			if (loopLead.Phone != null) {
				leadScore +=5;
			}
			if (loopLead.Industry == 'Technology') {
				leadScore += 10;
			}

			//Ensure that the proper Score was calculated
			Assert.areEqual(leadScore, loopLead.Lead_Score__c, 'The Score of this Lead was not calculated properly. Lead: ' + loopLead.FirstName + ' ' + loopLead.LastName);
		}
    }

    @IsTest
    static void testHandleLeadAutoConvert() {
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

		// Create new Leads and add them to a list
		List<Lead> newLeads = DataGenerator.leadGenerator();
    }
}