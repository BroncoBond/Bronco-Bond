const Website = require("../model/website.model");

exports.incrementClickCount = async (req, res) => {
    try {
        // Find the website document
        let website = await Website.findOne();

        // If the website document doesn't exist, create it
        if (!website) {
            website = await Website.create({ totalClickCount: 1 });
        } else {
            // If the website document does exist, increment totalClickCount
            website.totalClickCount += 1;
            await website.save();
        }

        res.status(200).json(website);
    } catch (err) {
        console.log("Error in incrementClickCount controller: ", err.message);
        res.status(500).json({ error: "Internal server error"});
    }
}

exports.resetToZero = async (req, res) => {
    try {
        // Find the website document
        let website = await Website.findOne();

        // If the website document doesn't exist, create it
        if (!website) {
            website = await Website.create({ totalClickCount: 0 });
        } else {
            // If the website document does exist, set totalClickCount to 0
            website.totalClickCount = 0;
            await website.save();
        }

        res.status(200).json(website);
    } catch (err) {
        console.log("Error in resetToZero controller: ", err.message);
        res.status(500).json({ error: "Internal server error"});
    }
}

exports.getTotalClickCount = async (req, res) => {
    try {
        // Find the website document
        let website = await Website.findOne();

        // If the website document doesn't exist, create it
        if (!website) {
            return res.status(200).json({ totalClickCount: 0 });
        } else {
            // If the website document does exist, return totalClickCount
            return res.status(200).json({ totalClickCount: website.totalClickCount });
        }
    } catch (err) {
        console.log("Error in getTotalClickCount controller: ", err.message);
        res.status(500).json({ error: "Internal server error"});
    }
}