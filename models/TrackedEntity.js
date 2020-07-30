//Require Mongoose
const mongoose = require('mongoose');
const uniqueValidator = require('mongoose-unique-validator');
const Category = require('./Category');

//Define a schema
const Schema = mongoose.Schema;

const TrackedEntitySchema = new Schema({
  name: { type: String, unique : true, required : true, lowercase: true, trim: true },
  class: [{ type: mongoose.ObjectId, ref: Category }],
  location: { latitude: Number, longitude: Number, time: Date },
  updated: { type: Date, default: Date.now() },
}, {timestamps: true});

TrackedEntitySchema.plugin(uniqueValidator, { message: 'is already taken.' });

TrackedEntitySchema.methods.setLocation = function (location) {
    if (location != []) {
        this.location.latitude = location.latitude;
        this.location.longitude = location.longitude;
        this.location.time = new Date();
        console.log(this.location)
    }
}

module.exports = mongoose.model('TrackedEntity', TrackedEntitySchema );