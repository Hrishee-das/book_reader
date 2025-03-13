const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const globalErrorHandler = require("./controllers/errorController");

dotenv.config({ path: "./config.env" });

const app = express();

// ✅ Middleware
app.use(express.json());
app.use(cors());
app.use("/uploads", express.static("uploads"));

// ✅ Import Routes
const bookRouter = require("./routes/bookRoutes");
const userRouter = require("./routes/userRoutes");

// ✅ Register Routes
app.use("/api/books", bookRouter);
app.use("/api/users", userRouter);

// Handle undefined routes
app.all("*", (req, res) => {
  res.status(404).json({ message: "Route not found!" });
});

app.use(globalErrorHandler);

module.exports = app;
