const mongoose = require('mongoose');

//Define a schema
const Schema = mongoose.Schema;

var CategorySchema = new Schema({
  name:{ type: String, required : true, lowercase: true, trim: true },
  tree: {
    root_id:this,
    parent_id:this,
  }
});

module.exports = mongoose.model('Category', CategorySchema );