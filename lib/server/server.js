import express from "express";
import mongoose from "mongoose";
import bodyParser from "body-parser";
import cors from "cors";

// Khởi tạo ứng dụng
const app = express();

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Kết nối MongoDB
const uri = "mongodb://localhost:27017/Notes";
mongoose
  .connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => {
    console.log("Đã kết nối với cơ sở dữ liệu MongoDB Note_app");
  })
  .catch((err) => {
    console.error("Lỗi kết nối với MongoDB", err);
  });

// Định nghĩa schema và model
const noteSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String, required: true },
  priority: { type: String, required: true },
  color: { type: String, required: true },
  date: { type: Date, required: true },
});

const Note = mongoose.model("Note", noteSchema, "Notes_list");

// Các API CRUD
// Lấy tất cả các ghi chú
app.get("/api/Notes_list", async (req, res) => {
  try {
    const Notes_list = await Note.find();
    res.json(Notes_list);
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi lấy danh sách ghi chú", error: err.message });
  }
});

// Thêm ghi chú mới
app.post("/api/Notes_list", async (req, res) => {
  const { title, description, priority, color, date } = req.body;
  if (!title || !description || !priority || !color || !date) {
    return res.status(400).json({ message: "Thiếu thông tin bắt buộc" });
  }

  try {
    const newNote = new Note({
      title,
      description,
      priority,
      color,
      date,
    });

    // Lưu vào MongoDB
    const savedNote = await newNote.save();
    res.status(201).json(savedNote);
  } catch (err) {
    res.status(400).json({ message: "Lỗi khi lưu ghi chú", error: err.message });
  }
});

// Lấy một ghi chú theo ID
app.get("/api/Notes_list/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const note = await Note.findById(id);
    if (!note) {
      return res.status(404).json({ message: "Ghi chú không tồn tại" });
    }
    res.json(note);
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi lấy ghi chú", error: err.message });
  }
});

// Cập nhật một ghi chú theo ID
app.put("/api/Notes_list/:id", async (req, res) => {
  const { id } = req.params;
  const { title, description, priority, color, date } = req.body;

  try {
    const updatedNote = await Note.findByIdAndUpdate(
      id,
      { title, description, priority, color, date },
      { new: true, runValidators: true }
    );

    if (!updatedNote) {
      return res.status(404).json({ message: "Ghi chú không tồn tại" });
    }

    res.json(updatedNote);
  } catch (err) {
    res.status(400).json({ message: "Lỗi khi cập nhật ghi chú", error: err.message });
  }
});

// Xóa một ghi chú theo ID
app.delete("/api/Notes_list/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const deletedNote = await Note.findByIdAndDelete(id);
    if (!deletedNote) {
      return res.status(404).json({ message: "Ghi chú không tồn tại" });
    }
    res.json({ message: "Ghi chú đã bị xóa", note: deletedNote });
  } catch (err) {
    res.status(500).json({ message: "Lỗi khi xóa ghi chú", error: err.message });
  }
});

// Chạy server
const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
