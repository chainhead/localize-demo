const express = require('express')
const app = express()
const rp = require('request-promise')
//
app.get('/demo/:lang', (req, res, next) => {
    var options = {
        method: "GET",
        uri: "http://172.17.0.2:3001/localize",
        body: {
            "lang": req.params.lang,
            "msg": {
                "MSG001E: $[1], $[2]": {
                    "1": "param1",
                    "2": "param2"
                }
            }
        },
        json: true
    }
    //
    rp(options).then((resp) => {
        res.status(200).send(resp)
    }).catch((e) => {
        res.status(500).send({
            msg : e
        })
    })
})
//
app.listen(3000);