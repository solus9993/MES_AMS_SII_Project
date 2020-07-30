const mongoose = require('mongoose');
const uniqueValidator = require('mongoose-unique-validator');
const Role = require('./Role');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const secret = require('../config').secret;
//Define a schema
const Schema = mongoose.Schema;

var UserSchema = new Schema({
    name: { type: String, lowercase: true, unique: true, required: [true, "can't be blank"], match: [/^[a-zA-Z0-9]+$/, 'Must be alphanumeric'], index: true },
    email: {
        type: String,
        trim: true,
        lowercase: true,
        unique: true,
        required: 'Email address is required',
        // validate: [{ validator: validateEmail, msg: 'Please fill a valid email address' }],
        match: [/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, 'Invalid email address, format: name@email.com']
    },
    roles: [{ type: mongoose.ObjectId, ref: Role }],
    shareLocation: { type: Boolean, default: false },
    location: { latitude: Number, longitude: Number, time: Date },
    mapVisible: { type: Boolean, default: false },
    hash: { type: String, required: true, select: false },
    salt: { type: String, required: true, select: false },
    active: { type: Boolean, default:true }
}, { timestamps: true });

var validateEmail = function (email) {
    var re = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
    return re.test(email)
};

UserSchema.plugin(uniqueValidator, { message: 'is already taken.' });

UserSchema.methods.setLocation = function (location) {
    if (location != []) {
        this.location.latitude = location.latitude;
        this.location.longitude = location.longitude;
        this.location.time = new Date();
        console.log(this.location)
    }
}

UserSchema.methods.setPassword = function (password) {
    console.log(password)
    this.salt = crypto.randomBytes(16).toString('hex');
    this.hash = crypto.pbkdf2Sync(password, this.salt, 10000, 512, 'sha512').toString('hex');
};

UserSchema.methods.validPassword = function (password) {
    const hash = crypto.pbkdf2Sync(password, this.salt, 10000, 512, 'sha512').toString('hex');
    return this.hash === hash;
};

/**
 * generates the jwt token
 */
UserSchema.methods.generateJWT = function () {
    let today = new Date();
    let exp = new Date(today);
    exp.setDate(today.getDate() + 60);

    return jwt.sign({
        id: this._id,
        name: this.name,
        exp: parseInt(exp.getTime() / 1000),
    }, secret);
};

UserSchema.methods.toAuthJSON = function () {
    return {
        _id: this._id,
        name: this.name,
        email: this.email,
        shareLocation: this.shareLocation,
        location: this.location,
        roles: this.roles,
        token: this.generateJWT(),
    };
};

module.exports = mongoose.model('User', UserSchema);