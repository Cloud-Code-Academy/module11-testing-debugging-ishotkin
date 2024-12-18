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

        // Create 15 Leads and add to list
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

    private static contactGenerator() {
        return null;
    }
}