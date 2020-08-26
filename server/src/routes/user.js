let express = require("express");
let router = express.Router();

router.get("/", (req, res) => {
  res.send({
    page: 1,
    total_pages: 1,
    results: [
      {
        id: "6dda2be7-11c5-44e5-b552-f22fa7ad8a4c",
        name: "Quabynah Bilson",
        email: "quabynahdennis@gmail.com",
        avatar:
          "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
      },
    ],
  });
});

router.get("/:id", (req, res) => {
  res.send({
    page: 1,
    total_pages: 1,
    results: {
      id: req.params.id,
      name: "Quabynah Bilson",
      email: "quabynahdennis@gmail.com",
      avatar:
        "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
    },
  });
});

router.post("/cart/new", (req, res) => {
  // TODO: add item to cart here
  res.send({
    page: 1,
    total_pages: 1,
    results: req.body,
  });
});

router.get("/cart", (req, res) => {
  // TODO: show cart items
  res.send({
    page: 1,
    total_pages: 1,
    results: [],
  });
});

module.exports = router;
