let express = require("express");
let router = express.Router();

router.post("/", (req, res) => {
  let body = req.body;
  console.log(`Request body -> ${body}`);
  res.send({
    page: 1,
    total_pages: 1,
    results: {
      api_version: "6dda2be7-11c5-44e5-b552-f22fa7ad8a4c",
    },
  });
});

module.exports = router;
