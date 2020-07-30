var config = {
    mongodb: 'mongodb+srv://mongo_user:mongo_pass@cluster0-oswkr.gcp.mongodb.net/project?retryWrites=true&w=majority',
    secret: 'sdkljhv93048hfv89ren',
    port: 3000,
    // baseURL: "http://localhost",
    baseURL: "https://tracker-app-api.herokuapp.com",
    // baseURL: "http://testcenas.ddns.net",
    cronZoneCount: true,
    permissions:{
        admin: 'admin_permission',
        request_all_users: 'request_all_users',
    }
}

module.exports = config;