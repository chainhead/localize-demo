const jp = require('fast-json-patch')
//
function mutate(admissionReviewRequest, callback) {
    let jsonPatch = {}
    return callback(null, jsonPatch)
}
//
module.exports = { mutate }