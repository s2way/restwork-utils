'use strict'

path = require 'path'
uuid = require 'node-uuid'

class HttpConnector

    constructor: (container) ->
        @restify = container?.restify || require 'restify'

    post: (params, callback) ->
        client = @restify.createStringClient url:params.url

        path = params?.path || ''

        client.post path, params?.data, (err, req, res, data) ->
            return callback err if err?
            callback null, data

module.exports = HttpConnector