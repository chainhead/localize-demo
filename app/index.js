const express = require('express')
const app = express()
const bp = require('body-parser')
//
var Localize = require('localize');
var localizedMessages = new Localize({
    "MSG001E: $[1], $[2]": {
        "en": "en - Database stopped - $[1], $[2]",
        "hi": "hi - Database stopped - $[1], $[2]",
        "kn": "kn - Database stopped - $[1], $[2]"
    }
})
//
//
app.use(bp.json())
//
app.get('/localize', (req, res, next) => {
    let payload = req.body
    localizedMessages.setLocale(payload.lang)
    let key = Object.keys(payload.msg)[0]
    let val = payload.msg[key]
    let translatedMessage = localizedMessages.translate(key, val["1"], val["2"])
    res.status(200).send({
        key: key,
        msg: translatedMessage
    });
})
//
app.listen(3001);