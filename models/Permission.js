const mongoose = require('mongoose');
const uniqueValidator = require('mongoose-unique-validator');
//Define a schema
const Schema = mongoose.Schema;

var permissionSchema = new Schema({
  name:{ type: String, required : true, lowercase: true, trim: true, unique: true },
}, {timestamps: true});
permissionSchema.plugin(uniqueValidator, {message: 'is already taken.'});
module.exports = mongoose.model('Permission', permissionSchema );