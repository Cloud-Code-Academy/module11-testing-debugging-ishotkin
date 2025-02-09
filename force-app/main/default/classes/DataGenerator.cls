    /*
    * The 'DataGenerator' class contains methods with which to create test data for use with the 'LeadTriggerTest.cls' class.
    * Each method will return a list of records that can then be inserted by the test class.
    * 
    */

public with sharing class DataGenerator {
    /*
    * The 'leadGenerator' method will return a list of leads with varying data. All have different Titles, and the Score varies by what data is provided.
    * 
    * @return List<Lead> The list of Leads with varying data to test Title and Score updates
    */

    @TestVisible
    private static List<Lead> leadGenerator() {
        // List to hold leads to be returned
        List<Lead> newLeads = new List<Lead>();

        // Create lists of data to use in Lead generation
        List<String> leadTitles = new List<String>{null,
            'vp Sales','Company V.P.','vice President',
            'Team MGR','manage','head of department',
            'Exec.','chief money person','head of company',
            'admin assist','deputy receptionist','CFO JR',
            'Boss','Intern'};

        List<String> leadIndustries = new List<String>{
            null,'Technology',null,null,'Technology',
            null,'Technology','Technology','Media','Banking',
            'Retail','Other',null,'Technology','Insurance'};

        List<String> leadEmails = new List<String>{
            null,'lead2@gmail.com','lead3@gmail.com',null,null,
            'lead6@gmail.com',null,'lead8@gmail.com','lead9@gmail.com',null,
            'lead11@gmail.com',null,null,'lead14@gmail.com','lead15@gmail.com'};

        List<String> leadPhones = new List<String>{
            null,'6179270002',null,'6179270004',null,
            '6179270006','6179270007',null,'6179270009','6179270010',
            null,null,null,'6179270014','6179270015'};

        List<String> leadSources = new List<String>{
            null,'Website','Website',null,'Other',
            'Website',null,'Website','Website','Phone Inquiry',
            'Website',null,null,'Other',null};

        // Create 15 Leads and add each to the list
        for (Integer i=0; i<15; i++) {
            Lead loopLead = new Lead();
            loopLead.LastName = 'Lead' + (i + 1);
            loopLead.Company = 'Leads Inc.';
            loopLead.Title = leadTitles[i];
            loopLead.Industry = leadIndustries[i];
            loopLead.Email = leadEmails[i];
            loopLead.Phone = leadPhones[i];
            loopLead.LeadSource = leadSources[i];            

            // Add leads to the list
            newLeads.add(loopLead);
        }

        // Return the list of Leads
        return newLeads;
    }

    @TestVisible
    private static List<Contact> contactGenerator() {
        // Create an Account to use for the Contacts
        Account testAccount =  new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create a list to hold the Contacts
        List<Contact> newContacts = new List<Contact>();

        // Create lists of data to use in Contact creation
        List<String> contactEmails = new List<String>{null, 'lead2@gmail.com','lead2@gmail.com','lead3@gmail.com','contact4@gmail.com',
            'lead2@gmail.com','lead6@gmail.com','lead7@gmail.com','lead8@gmail.com','lead11@gmail.com',null,'lead7@gmail.com'};

        // Create 12 new Contacts and add them to the list
        for (Integer i=0; i<12; i++) {
            Contact newCon = new Contact();
            newCon.LastName = 'Contact' + (i + 1);
            newCon.Email = contactEmails[i];
            newCon.Account = testAccount;
            newContacts.add(newCon);
        }

        // Return the list of Contacts
        return newContacts;
    }

    @TestVisible
    private static List<Lead> leadUpdater(String newEmail, List<Lead> leads){
        // Set the email address of the leads with no Email to that of the Contact
        for (Lead l : leads) {
            if (l.Email == null) {
                l.Email = newEmail;
            }
        }
        // Return the updated Leads
        return leads;
    }
}