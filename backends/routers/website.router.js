const router = require('express').Router();
const websiteController = require("../controller/website.controller");

router.post("/incrementTotalClick", websiteController.incrementClickCount);

//router.post("/reset", websiteController.resetToZero);

router.get("/getTotalClick", websiteController.getTotalClickCount);

module.exports = router;