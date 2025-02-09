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
    static void testHandleLeadAutoConvertCreation() {
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

		// Create new Contacts and insert, bypassing duplicate rules
		List<Contact> newContacts = DataGenerator.contactGenerator();
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;
		dml.DuplicateRuleHeader.RunAsCurrentUser = true;
		Database.insert(newContacts, dml);

		// Insert the Leads
		test.startTest();
		insert newLeads;
		system.debug(newLeads);
		test.stopTest();

		// Query the created Contacts and Leads
		List<Contact> createdContacts = [SELECT LastName, Email FROM Contact];
		List<Lead> createdLeads = [SELECT LastName, Email, isConverted, ConvertedContactId FROM Lead];

		// Create a map to match converted Leads with their Contacts
		Map<Id, Id> contactToLead = new Map<Id, Id>();
		for (Lead newLead : createdLeads) {
			if (newLead.IsConverted) {
				contactToLead.put(newLead.ConvertedContactId, newLead.Id);
			}
		}

		// Create map to hold unique Email with Converted Lead's ID
		Map<Id, String> uniqueMap = new Map<Id, String>();
		// Create list to hold duplicate Emails
		List<String> duplicateList = new List<String>();

		// Add each Contact to the map unless the email is a duplicate, in which case add to list
		for (Contact newCon : createdContacts) {
			if (newCon.Email == null) {
				// If the Email is null, continue to the next iteration of the loop
				continue;
			} else if (duplicateList.contains(newCon.Email)) {
				// Contnue to next interation of loop if the email is already identified as a duplicate
				continue;
			} else if (uniqueMap.values().contains(newCon.Email)) {
				// Remove the Email from the Map keyset and add to dupe list if it is found a second time
				uniqueMap.remove(contactToLead.get(newCon.Id));
				duplicateList.add(newCon.Email);
			} else {
				// If not a duplicate email, add Email and Lead ID to the map
				uniqueMap.put(contactToLead.get(newCon.Id), newCon.Email);
			}
		}

		// Get a count of Leads that have been converted
		Integer convertedLeads = 0;

		for (Lead newLead : createdLeads) {
			if (newLead.IsConverted) {
				convertedLeads++;
			}
		}

		// Create variables to hold the number of converted Leads that we wanted converted
		Integer leadCount = 0;

		// Check that if a Lead's Email is in the map keyset, its ID is in the valueset.
		for (Lead newLead : createdLeads) {
			if (newLead.Email != null && uniqueMap.values().contains(newLead.Email)) {
				// Confirm that the Lead was converted if exactly 1 Contact with its Email exists
				Assert.isTrue(uniqueMap.containsKey(newLead.Id), 'This Lead was not coverted when it should have been.');
				// Confirm that the Lead was converted to the correct Contact
				Assert.areEqual(newLead.Id, contactToLead.get(newLead.ConvertedContactId), 'This Lead was converted to the wrong Contact');
				// Increment counter
				leadCount++;
			}
		}

		// Check that the size of leadCount is equal to the number of converted Leads to ensure the correct number were converted
		Assert.areEqual(convertedLeads, leadCount, 'The wrong number of leads were converted.');
    }

	@IsTest
	public static void testHandleLeadAutoConvertUpdate(){
	/* 
	 * Question 3.5
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

		// Create and insert a list of Leads
		insert DataGenerator.leadGenerator();

		// Create and insert an Account and a Contact
		Account acc = new Account(Name = 'Test Account');
		insert acc;
		insert new Contact(LastName = 'LeadTester', Email = 'leadTester@gmail.com', Account = acc);

		// Query the created Leads and Contact
		List<Lead> createdLeads = [SELECT Id, LastName, Email, IsConverted, ConvertedContactId FROM Lead];
		Contact testCon = [SELECT Id, LastName, Email FROM Contact LIMIT 1];

		// Update the Leads' Email address
		List<Lead> newLeadEmail = DataGenerator.leadUpdater(testCon.Email, createdLeads);
		
		test.startTest();
		update newLeadEmail;
		test.stopTest();

		// Query the updated Leads
		List<Lead> updatedLeads = [SELECT LastName, Email, isConverted, ConvertedContactId FROM Lead];
		
		// Get count of Leads with the Contact's Email and count of converted Leads
		Integer emailMatch = 0;
		Integer convertedCount = 0;

		for (Lead l : updatedLeads) {
			if (l.Email == testCon.Email) {
				emailMatch++;
			}
			if (l.IsConverted) {
				convertedCount++;
			}
		}

		// Confirm that the 2 counts match as the Leads shoud have been converted if and only iff the Email matches
		Assert.areEqual(emailMatch, convertedCount, 'An incorrect amount of Leads were converted.');

		// Confirm the Contact for each converted Lead is the testCon
		for (Lead l : updatedLeads) {
			if (l.IsConverted) {
				Assert.areEqual(testCon.Id, l.ConvertedContactId, 'This Lead was not converted to the correct Contact');
			}
		}
	}
}