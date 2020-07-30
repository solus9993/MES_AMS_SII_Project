var express = require('express');
var router = express.Router();
var Collection = require('../models/Permission.js');

// GET ALL 
router.get('/', function (req, res, next) {
  Collection.find(function (err, result) {
        if (err) return res.status(500).json({ error: err });
        res.json(result);
    });
});

// GET SINGLE BY ID
router.get('/:id', function (req, res, next) {
  Collection.findById(req.params.id, function (err, result) {
        if (err) return res.status(500).json({ error: err });
        res.json(result);
    });
});

// SAVE
router.post('/', function (req, res, next) {
  Collection.create(req.body, function (err, result) {
        if (err) return res.status(500).json({ error: err });
        console.log(result)
        res.json(result);
    });
});


// UPDATE 
router.put('/', function (req, res, next) {
  Collection.findByIdAndUpdate(req.body.id, req.body, function (err, result) {
        if (err) return res.status(500).json({ error: err });
        res.json(result);
    });
});

// DELETE 
router.delete('/:id', function (req, res, next) {
  Collection.findByIdAndRemove(req.params.id, function (err, result) {
        if (err) return res.status(500).json(err);
        res.json(result);
    });
});

module.exports = router;
