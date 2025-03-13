const mongoose = require("mongoose");

const BookSchema = new mongoose.Schema({
  title: String,
  filePath: String,
});
const Book = mongoose.model("Book", BookSchema);

module.exports = Book;
