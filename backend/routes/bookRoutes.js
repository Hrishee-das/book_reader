const express = require("express");
const multer = require("multer");
const path = require("path");
const bookController = require("./../controllers/bookController");

const router = express.Router();

// Multer Config for File Upload
const storage = multer.diskStorage({
  destination: "uploads/",
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

// Correctly use `router` instead of `app`
router.post("/upload", upload.single("book"), bookController.uploadBook);
router.get("/", bookController.getBooks);
router.get("/:id", bookController.getBookById);
router.delete("/:id", bookController.deleteBook);

module.exports = router;
