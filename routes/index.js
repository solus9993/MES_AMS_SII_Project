var express = require('express');
var router = express.Router();
var app = express();
/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

var trackedentityRouter = require('./trackedEntity');
var categoryRouter = require('./category');
var zoneRouter = require('./zone');

var permissionRouter = require('./permission');
var roleRouter = require('./role');
var userRouter = require('./user');

app.use('/', router);

app.use('/trackedentity', trackedentityRouter);
app.use('/category', categoryRouter);
app.use('/zone', zoneRouter);

app.use('/permission', permissionRouter);
app.use('/role', roleRouter);
app.use('/user', userRouter);

module.exports = app;
