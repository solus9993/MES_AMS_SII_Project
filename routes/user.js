const express = require('express');
const router = express.Router();
const { check, validationResult } = require("express-validator");
const Collection = require('../models/User.js');
var config = require('../config');
const { auth, hasPermissions, getPayload } = require('./auth');

router.get('/filter*', auth.required, async function (req, res, next) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        console.log(errors);
        return res.status(400).json({
            errors: errors.array()
        });
    }
    const payload = getPayload(req);
    const hasPermission = await hasPermissions(req, config.permissions.request_all_users);
    // one user details requested and is not self details
    if ( req.query.name != null && !(payload.name == req.query.name)) {
        return res.status(401).json({
            'message': 'Unauthorized Error'
        });
    }
    //does not has permission to request all users
    if(!hasPermission && !(payload.name == req.query.name)){
        //only show user with map visible on
        req.query.mapVisible = true;
    }
    console.log(req.query);
    Collection.find(req.query)
        .select({})
        .populate({
            path: 'roles',
        })
        .exec(function (err, result) {
            console.log(err);
            if (err) return res.status(500).json(err);
            console.log(result);
            res.json(result);
        });
});

// GET ALL 
router.get('/', auth.optional, function (req, res, next) {
    Collection.find(function (err, result) {
        if (err) return res.status(500).json(err);
        res.json(result);
    });
});

// GET SINGLE BY ID
router.get('/:id', function (req, res, next) {
    Collection.findById(req.params.id, function (err, result) {
        if (err) return res.status(500).json(err);
        res.json(result);
    });
});

// SAVE
router.post('/', [
    check("name", "Invalid display name. Field empty.")
        .not()
        .isEmpty(),
    check("email", "Invalid email. Format: name@email.com").isEmail(),
    check("password", "Invalid password, at least 6 characters needed.").isLength({
        min: 6
    })
],
    function (req, res, next) {
        const errors = validationResult(req);

        if (!errors.isEmpty()) {
            // console.log(req.body)
            return res.status(400).json({
                errors: errors.array()
            });
        }
        let user = new Collection(req.body);
        user.setPassword(req.body.password);
        Collection.create(user, function (err, result) {
            if (err) return res.status(500).json(err);
            // console.log(result)
            res.json({ 'message': 'Success' });
        });
    });


// UPDATE 
router.put('/', auth.required, function (req, res, next) {
    let collection = new Collection(req.body);
    if (req.body.location != null) collection.setLocation(req.body.location);
    Collection.findByIdAndUpdate(req.body._id, collection, function (err, result) {
        if (err) return res.status(500).json(err);
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


/**
 * authenticates the user credentials
 */
router.post('/signin', [
    check('name', "NAME or Email: is empty")
], (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            errors: errors.array()
        });
    }

    // requests user
    Collection.findOne({
        $or: [{ name: req.body.name.trim() }, { 'email': req.body.name.trim() }]
    }).select('+salt +hash')
        .populate("roles", "-__v")
        .exec((err, user) => {
            console.log(user)
            // request error
            if (err) return res.status(500).json(err);
            // user does not exits
            if (!user) return res.status(404).send({ message: "Credentials do not match." });
            // password is valid for user
            if (!user.validPassword(req.body.password)) {
                return res.status(401).send({
                    token: null,
                    message: "Credentials do not match."
                });
            }
            // adds token to user info
            const authJSON = user.toAuthJSON();
            res.status(200).send(authJSON);
        });
});

module.exports = router;
