const puppeteer = require('puppeteer'); // Node.js library that navigates the webpage, interacts, and extracts data

async function scrapeEventDetails() {
    // Initializes and launches browser
    const browser = await puppeteer.launch();
    // Creates a new tab
    const page = await browser.newPage();

    // Define URL for the event
    const url = 'https://mybar.cpp.edu/event/9859501';

    // Navigate to URL
    await page.goto(url);

    // Evaluate page to extract event details
    const eventDetails = await page.evaluate(() => {
        const data = window.initialAppState.preFetchedData.event; // The event data is stored in JavaScrip object that is assigned to window.initialAppState
        return {
            title: data.name,
            description: data.description,
            startsOn: data.startsOn,
            endsOn: data.endsOn,
            location: data.address.name,
            onlineLocation: data.address.onlineLocation // For events not in person
        };
    });

    // Print event details
    console.log(eventDetails);

    // Close browser
    await browser.close();
}

// Calls function
scrapeEventDetails();
