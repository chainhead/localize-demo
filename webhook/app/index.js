const fs = require('fs')
const express = require('express')
const bodyParser = require('body-parser')
const https = require('https')
//
const mutate = require('./mutate')
//
const app = express()
app.use(bodyParser.json())
//
app.post('/', (req, res, next) => {
    console.log('Request received - ', req.body.request.uid)
    mutate.mutate(req.body.request, (err, res) => {
        if (err) {
            res.status(500).send({})
        } else {
            console.log('Response created - ', JSON.stringify(res))
            res.status(200).send({
                kind: req.body.kind,
                apiVersion: req.body.apiVersion,
                request: req.body.request,
                response: res
            })
        }
    })
})
//
https.createServer({
    key: fs.readFileSync('/etc/certs/tls.key'),
    cert: fs.readFileSync('/etc/certs/tls.crt')
}, app).listen(4443);
