var jsonwebtoken = require('jsonwebtoken');
var jwt = require('express-jwt');
var config = require('../config');
const Collection = require('../models/User.js');

function getTokenFromHeader(req) {
    // console.log(req.headers)
    if (req.headers.authorization && req.headers.authorization.split(' ')[0] === 'Token') {
        return req.headers.authorization.split(' ')[1];
    }

    return null;
}

/**
 * checks if the requester has a specific premission,
 * returns true if user has permission
 * @param {*} req 
 * @param {*} askedPermission 
 */
async function hasPermissions(req, askedPermission) {
    let payload = getPayload(req)
    let result;
    try {
        result = await Collection.findById(payload.id)
        .select({})
        .populate({
            path: 'roles',
            populate: [{
                path: 'permissions',
            },]
        })
        .exec();
    } catch (error) {
        throw error;
    }
    
    let permissions = [];
    result.roles.forEach(role => {
        role.permissions.forEach(permission => {
            permissions.push(permission.name);
        });
    });
    if (permissions.includes(config.permissions.admin) || permissions.includes(askedPermission)) {
        console.log('premission granted')
        return true;
    }
    return false;
}

function getPayload(req) {
    token = getTokenFromHeader(req);
    dtoken = jsonwebtoken.decode(token, { complete: true });
    return dtoken.payload;
}

var auth = {
    admin: jwt({
        algorithms: ['HS256'],
        secret: config.secret,
        userProperty: {
            permissions: [config.permissions.admin]
        },
        getToken: getTokenFromHeader,
    }),
    required: jwt({
        algorithms: ['HS256'],
        secret: config.secret,
        userProperty: 'payload',
        getToken: getTokenFromHeader,
    }),
    optional: jwt({
        algorithms: ['HS256'],
        secret: config.secret,
        userProperty: 'payload',
        credentialsRequired: false,
        getToken: getTokenFromHeader
    })
};

module.exports = { auth, hasPermissions, getPayload };