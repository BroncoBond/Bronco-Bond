const puppeteer = require('puppeteer');

async function scrapeEventDetails() {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto('https://mybar.cpp.edu/event/9701405');

    // Evaluate script to extract event details
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

    console.log(eventDetails);

    await browser.close();
}

scrapeEventDetails();
