const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config(); // <-- load .env

const app = express();
app.use(cors());
app.use(express.json()); // parse JSON requests

// ---------------- Connect MongoDB ----------------
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.error("MongoDB connection error:", err));

// ---------------- Define Event Schema ----------------
const eventSchema = new mongoose.Schema({
  eventType: String,
  country: String,
  stateName: String,
  city: String,
  eventDates: [String], // store as strings
  adults: Number,
  veg: Boolean,
  nonVeg: Boolean,
  cuisine: String,
  budget: Number,
  currency: String,
  responseTime: String,
}, { timestamps: true });

const Event = mongoose.model("Event", eventSchema);

// ---------------- POST API to save event ----------------
app.post("/api/events", async (req, res) => {
  console.log("Received POST request at /api/events");
  console.log("Request body:", req.body);

  try {
    if (req.body.eventDates) {
      req.body.eventDates = req.body.eventDates.filter(d => d != null);
    }

    const newEvent = new Event(req.body);
    await newEvent.save();
    console.log("Event saved successfully in MongoDB");
    res.json({ success: true, message: "Event saved successfully" });
  } catch (err) {
    console.error("Error saving event:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ---------------- GET API to fetch all events ----------------
app.get("/api/events", async (req, res) => {
  try {
    const events = await Event.find().sort({ createdAt: -1 });
    res.json(events);
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ---------------- Start Server ----------------
const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running at http://0.0.0.0:${PORT}`);
});
