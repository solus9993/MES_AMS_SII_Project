var express = require('express');
var router = express.Router();
var Collection = require('../models/TrackedEntity.js');

router.get('/filter*', function (req, res, next) {
    console.log("FILTER")
    console.log(new Date());
    console.log(req.query)
    Collection.find(req.query).populate({
        path: 'class',
        populate: [{
            path: 'tree.root_id',
            model: 'Category'
        },
        {
            path: 'tree.parent_id',
            model: 'Category'
        }]
    }).exec(function (err, result) {
        if (err) return res.status(500).json({ error: err });
        res.json(result);
    });
});


// GET ALL
router.get('/', function (req, res, next) {
    console.log("FindALL")
    console.log(new Date());
    Collection.find(function (err, result) {
        if (err) return res.json({ error: err });
        res.json(result);
    });
});


// GET SINGLE BY ID
router.get('/:_id', function (req, res, next) {
    console.log(new Date());
    Collection.findById(req.params._id, function (err, result) {
        if (err) return res.json({ error: err });
        res.json(result);
    });
});

// SAVE
router.post('/', function (req, res, next) {
    Collection.create(req.body, function (err, result) {
        if (err) return res.json({ error: err });
        res.json(result);
    });
});


// UPDATE
router.put('/', function (req, res, next) {
    Collection.findByIdAndUpdate(req.body._id, req.body, function (err, result) {
        if (err) return res.json({ error: err });
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
