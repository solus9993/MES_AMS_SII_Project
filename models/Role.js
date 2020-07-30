const mongoose = require('mongoose');
const uniqueValidator = require('mongoose-unique-validator');
const Permission = require('./Permission');
//Define a schema
const Schema = mongoose.Schema;

var RoleSchema = new Schema({
  name:{ type: String, required : true, lowercase: true, trim: true },
  permissions:[{ type: mongoose.ObjectId, ref: Permission }],
}, {timestamps: true});
RoleSchema.plugin(uniqueValidator, {message: 'is already taken.'});
module.exports = mongoose.model('Role', RoleSchema );