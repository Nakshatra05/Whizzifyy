require("dotenv").config();
const mongoose = require("mongoose");

const DB = process.env.DB;

mongoose.connect("mongodb+srv://nakshatragoel05:nakshatra@cluster0.dcxyqgd.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
    .then(() => console.log("DB successfully Connected"))
    .catch((err) => console.log(err));