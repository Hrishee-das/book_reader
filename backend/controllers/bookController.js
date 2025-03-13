const fs = require("fs");
const Book = require("./../models/bookModel");

exports.uploadBook = async (req, res) => {
  const book = new Book({
    title: req.file.originalname,
    filePath: req.file.path.replace(/\\/g, "/"), // Convert \ to /
  });
  await book.save();
  res.json({ message: "Book uploaded successfully", book });
};

exports.getBooks = async (req, res) => {
  const books = await Book.find();
  res.json(books);
};

exports.getBookById = async (req, res) => {
  const book = await Book.findById(req.params.id);
  res.json(book);
};

// Delete Book by ID
exports.deleteBook = async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) return res.status(404).json({ message: "Book not found" });

    // Delete the file from uploads folder
    fs.unlink(book.filePath, (err) => {
      if (err) console.error("Error deleting file:", err);
    });

    await Book.findByIdAndDelete(req.params.id);
    res.json({ message: "Book deleted successfully" });
  } catch (error) {
    console.log("Error deleting book:", error);
    res.status(500).json({ message: "Error deleting book", error });
  }
};
