'use strict'

path = require 'path'
uuid = require 'node-uuid'

class HttpConnector

    constructor: (container) ->
        @restify = container?.restify || require 'restify'

    post: (params, callback) ->
        if params?.type is 'json'
            client = @restify.createJsonClient url:params.url
        else
            client = @restify.createStringClient url: params.url

        path = params?.path || ''

        client.post path, params?.data, (err, req, res, data) ->
            return callback err if err?
            callback null, data

    get: (params, callback) ->
        if params?.type is 'json'
            client = @restify.createJsonClient url:params.url
        else
            client = @restify.createStringClient url:params.url

        path = params?.path || ''

        client.get path, (err, req, res, data) ->
            return callback err if err?
            callback null, data

module.exports = HttpConnector