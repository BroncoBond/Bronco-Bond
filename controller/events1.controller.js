const puppeteer = require('puppeteer');

// An asynchronous function 'scrapeEventDetails' to scrape event details
async function scrapeEventDetails() {
    // Launching a new browser instance
    const browser = await puppeteer.launch();

    // Creating a new page in the browser context
    const page = await browser.newPage();

    // URL for the events page
    const url = 'https://mybar.cpp.edu/events';

    // Navigating to the specified URL
    await page.goto(url);

    // Finding all event elements with a selector
    const events = await page.$$eval('#event-discovery-list .event-list-item.card a', elements => {
        // Mapping over the event elements and returning their URLs
        return elements.map(element => element.getAttribute('href'));
    });

    // Creating an empty list to store event details
    const eventDetailsList = [];

    // Iterating over the list of event URLs
    for (const eventUrl of events) {
        // Navigating to the event URL
        await page.goto(eventUrl);

        // Extracting the event details using the correct selector
        const eventDetails = await page.evaluate(() => {
            const data = JSON.parse(document.body.getAttribute('data-events'));
            const eventItem = data.filter(item => item.pageLink === window.location.href)[0];

            return {
                title: eventItem.name,
                description: eventItem.description.length > 0 ? eventItem.description.replace('<p>', '').replace('</p>', '') : '',
                startsOn: eventItem.startsOn,
                endsOn: eventItem.endsOn,
                location: eventItem.location.name,
                onlineLocation: eventItem.location.onlineLocation
            };
        });

        eventDetailsList.push(eventDetails);
    }

    // Log the event details list to the console
    console.log(eventDetailsList);

    // Closing the browser
    await browser.close();
}

// Calling the 'scrapeEventDetails' function to start the event details scraping
scrapeEventDetails();