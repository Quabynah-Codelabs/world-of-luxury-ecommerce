// Import express
let app = require("express")();
//Import the mongoose module
var mongoose = require("mongoose");
var morgan = require("morgan");
// Import product routes
let productsRoute = require("./routes/product");
// Import user routes
let usersRoute = require("./routes/user");

//Set up default mongoose connection
var mongoDB = "mongodb://127.0.0.1/swan_wol";
mongoose.connect(mongoDB, { useNewUrlParser: true, useUnifiedTopology: true });

//Get the default connection
var db = mongoose.connection;

//Bind connection to error event (to get notification of connection errors)
db.on("error", console.error.bind(console, "MongoDB connection error:"));

app.use(morgan("dev"));
app.use("/products", productsRoute);
app.use("/users", usersRoute);

// Connect to server
let server = app.listen(5000, () => {
  var host = server.address().address;
  var port = server.address().port;

  console.log("Swan app listening at http://%s:%s", host, port);
});

module.exports = app;
