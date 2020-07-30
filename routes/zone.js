var express = require('express');
var router = express.Router();
const { check, validationResult } = require("express-validator");
var Collection = require('../models/Zone.js');
const userCollection = require('../models/User');
const {auth, hasPermissions} = require('./auth');
const Commons = require('../utils/Commons');
const classifyPoint = require("robust-point-in-polygon");

// GET Filtered
router.get('/filter*', auth.required, function (req, res, next) {
  const errors = validationResult(req);
  Collection.find({ "name": { "$regex": Commons.escapeRegExp(`${req.query.name}`), "$options": "i" } })
    .select({})
    .populate(
      {
        path: 'owner',
      }
    )
    .exec(function (err, result) {
      if (err) return res.status(500).json(err);
      res.json(result);
    });
});

// GET ALL 
router.get('/', auth.required, function (req, res, next) {
  Collection.find()
    .populate({
      path: 'owner',
    })
    .exec(function (err, result) {
      if (err) return res.status(500).json(err);
      res.json(result);
    });
});

// GET SINGLE BY ID
router.get('/:id', auth.required, function (req, res, next) {
  Collection.findById(req.params.id, function (err, result) {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

// SAVE 
router.post('/', auth.required, function (req, res, next) {
  Collection.create(req.body, function (err, result) {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});


// UPDATE 
router.put('/', auth.required, function (req, res, next) {
  let collection = new Collection(req.body);
  Collection.findByIdAndUpdate(req.body._id, collection, function (err, result) {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

// UPDATE Count 
router.put('/recount', async function (req, res, next) {
  let insideCount = 0;
  let polygon = [];
  var oneHourOld = new Date();
  oneHourOld.setHours(oneHourOld.getHours() - 1);
  try {
    let zones = await Collection.find().exec();
    const users = await userCollection.find().exec();
    zones.forEach(zone => {
      insideCount = 0;
      polygon = [];
      zone.points.forEach(point => { polygon.push([point.latitude, point.longitude]) });
      users.forEach(user => {
        if (1 != classifyPoint(polygon, [user.location.latitude, user.location.longitude]) && user.location.time > oneHourOld) {
          insideCount++;
        }
      });
      if (zone.insideCount != insideCount) {
        zone.insideCount = insideCount;
        zone.save();
      }
    });
    return res.json();
  } catch (err) {
    err.stack;
  }
});

// DELETE 
router.delete('/:id', auth.required, function (req, res, next) {
  console.log(req.params)
  Collection.findByIdAndRemove(req.params.id, function (err, result) {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

module.exports = router;
