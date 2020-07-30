var cron = require('node-cron');
var axios = require('axios');
var config = require('../config');
/**
 * schedule auto zone count,
 * if cronZoneCount is true in config file
 */
exports.zoneCount = () => {
    if (config.cronZoneCount) {
        cron.schedule('*/10 * * * * *', () => {
            axios.all([
                axios.put(config.baseURL + ':' + config.port + '/zone/recount'),
            ]).then(axios.spread((response1) => {
                // console.log(response1.data.url);
            })).catch(error => {
                console.log(error);
            });
        });
    }
}