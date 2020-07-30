
const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const config = require('./config');

let app = express();

//Set up default mongoose connection
const mongoose = require('mongoose');
const mongoDB = config.mongodb;
mongoose.connect(mongoDB, { useUnifiedTopology: true, useNewUrlParser:true, useCreateIndex: true, useFindAndModify: false });
//Get the default connection
var db = mongoose.connection;
//Bind connection to error event (to get notification of connection errors)
db.on('error', console.error.bind(console, 'MongoDB connection error:'));

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');


app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));


// catch 404 and forward to error handler
// app.use(function(req, res, next) {
//   next(createError(404));
// });

//set routes
let routerApp = require('./routes/index');
app.use(routerApp._router);

// error handler
app.use(function(err, req, res, next) {
  console.log({'error handler':err});
  if (err.name === 'UnauthorizedError') {
    console.log('UnauthorizedError');
    return res.status(401).json(err);
  }
  // render the error page
  res.status(err.status || 500).send(err);;
  // res.render('error');
});

//activate schedule
var cron = require('./services/cron');
cron.zoneCount();

module.exports = app;
