var express = require('express');
var router = express.Router();
var Collection = require('../models/Category.js');

// GET ALL Category
router.get('/', function (req, res, next) {
  Collection.find(function (err, result) {
        if (err) res.json(err);
        res.json(result);
    });
});

// GET SINGLE Category BY ID
router.get('/:id', function (req, res, next) {
  Collection.findById(req.params.id, function (err, result) {
        if (err) res.json(err);
        res.json(result);
    });
});

// SAVE Category
router.post('/', function (req, res, next) {
  Collection.create(req.body, function (err, result) {
        if (err) res.json(err);
        console.log(result)
        res.json(result);
    });
});


// UPDATE Category
router.put('/', function (req, res, next) {
  Collection.findByIdAndUpdate(req.body.id, req.body, function (err, result) {
        if (err) res.json(err);
        res.json(result);
    });
});

// DELETE Category
router.delete('/:id', function (req, res, next) {
  Collection.findByIdAndRemove(req.params.id, function (err, result) {
        if (err) return res.status(500).json(err);
        res.json(result);
    });
});

module.exports = router;
