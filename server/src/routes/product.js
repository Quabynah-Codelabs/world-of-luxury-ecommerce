let express = require("express");
let router = express.Router();

router.post("/", (req, res) => {
  return res.send({
    page: 1,
    total_pages: 1,
    results: [
      {
        id: "3cad4b6b-6dfd-461d-991e-b79dffeb0886",
        name: "Cat Tee Black T-Shirt",
        description:
          "Nunc aliquet bibendum enim facilisis gravida neque. Maecenas sed enim ut sem viverra",
        category: "Shirt",
        style: "Black with custom print",
        price: 10.99,
        currency_id: "USD",
        currency_format: "$",
        shippable: true,
        photo_url:
          "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60",
      },
      {
        id: "591b2cc0-5fe1-4813-9a40-8c3f3bbd1fba",
        name: "Dark Thug Blue-Navy T-Shirt",
        description:
          "Pellentesque pulvinar pellentesque habitant morbi tristique senectus et. Vitae tempus quam pellentesque nec nam aliquam sem et tortor",
        category: "Shirt",
        style: "Front print and paisley print",
        price: 29.45,
        currency_id: "USD",
        currency_format: "$",
        shippable: true,
        photo_url:
          "https://images.unsplash.com/photo-1576566588028-4147f3842f27?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60",
      },
      {
        id: "46a23a80-c345-4d2c-9398-5bb5efcf7327",
        name: "Sphynx Tie Dye Wine T-Shirt",
        description:
          "Neque egestas congue quisque egestas diam in arcu. In nibh mauris cursus mattis",
        category: "Shirt",
        style: "Front tie dye print",
        price: 9,
        currency_id: "USD",
        currency_format: "$",
        shippable: true,
        photo_url:
          "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60",
      },
      {
        id: "d1a96e11-2468-437f-b768-27754644990c",
        name: "Skuul",
        description:
          "Amet est placerat in egestas erat. Mauris vitae ultricies leo integer malesuada nunc vel risus commodo",
        category: "Shirt",
        style: "Black T-Shirt with front print",
        price: 14.99,
        currency_id: "USD",
        currency_format: "$",
        shippable: true,
        photo_url:
          "https://images.unsplash.com/photo-1564859228273-274232fdb516?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60",
      },
      {
        id: "804510ba-eb39-4c2f-989a-db65b2021602",
        name: "Danger Knife Grey",
        description:
          "Sed sed risus pretium quam vulputate dignissim suspendisse. Neque ornare aenean euismod elementum nisi",
        category: "Shirt",
        style: "White with black stripes",
        price: 19.99,
        currency_id: "USD",
        currency_format: "$",
        shippable: false,
        photo_url:
          "https://images.unsplash.com/photo-1485043433441-db091a258e5a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60",
      },
      {
        id: "6dda2be7-11c5-44e5-b552-f22fa7ad8a4c",
        name: "Wine Skul T-Shirt",
        description:
          "Libero volutpat sed cras ornare arcu. Adipiscing bibendum est ultricies integer quis auctor. Urna cursus eget nunc scelerisque viverra mauris in",
        category: "Shirt",
        style: "Wine",
        price: 13.25,
        currency_id: "USD",
        currency_format: "$",
        shippable: false,
        photo_url:
          "https://images.unsplash.com/photo-1595136895914-da8f886a7ed8?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60",
      },
    ],
  });
});

router.get("/:id", (req, res) => {
  return res.send({
    page: 1,
    total_pages: 1,
    results: {
      id: "6dda2be7-11c5-44e5-b552-f22fa7ad8a4c",
      name: "Wine Skul T-Shirt",
      description:
        "Libero volutpat sed cras ornare arcu. Adipiscing bibendum est ultricies integer quis auctor. Urna cursus eget nunc scelerisque viverra mauris in",
      category: "Shirt",
      style: "Wine",
      price: 13.25,
      currency_id: "USD",
      currency_format: "$",
      shippable: false,
      photo_url:
        "https://images.unsplash.com/photo-1595136895914-da8f886a7ed8?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60",
    },
  });
});

module.exports = router;
