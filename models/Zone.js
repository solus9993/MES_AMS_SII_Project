const mongoose = require('mongoose');
const uniqueValidator = require('mongoose-unique-validator');
const User = require('./User');

//Define a schema
const Schema = mongoose.Schema;

var ZoneSchema = new Schema({
    name: { type: String, lowercase: true, unique: true, required: [true, "can't be blank"], index: true },
    points:
        [
            {
                latitude: { type: Number, required: true },
                longitude: { type: Number, required: true }
            }
        ],
    color: { type: Number, default: 0xFF2196F3 },
    entitiesInside: [{ type: mongoose.ObjectId, ref: User }],
    owner: { type: mongoose.ObjectId, ref: User, required: [true, "can't be blank"] },
    insideCount: { type: Number },
    insideLimit: { type: Number, required: [true, "can't be blank"], match: [/^[0-9]+$/, 'Must be numeric'] },
}, { timestamps: true });

function min3Points(val) {
    console.log("min3Points")
    console.log(val)
    return val.length < 3;
}
ZoneSchema.plugin(uniqueValidator, { message: 'is already taken.' });
ZoneSchema.methods.setEntitiesInside = () => {
    console.log('cenas');
}

module.exports = mongoose.model('Zone', ZoneSchema);