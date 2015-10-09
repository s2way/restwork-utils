'use strict'

path = require 'path'
uuid = require 'node-uuid'
qs = require 'querystring'

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

        path = "#{path}?#{qs.stringify(params.urlParams)}" if params?.urlParams?

        client.get path, (err, req, res, data) ->
            return callback err if err?
            callback null, data

    put: (params, callback) ->
        if params?.type is 'json'
            client = @restify.createJsonClient url:params.url
        else
            client = @restify.createStringClient url: params.url

        path = params?.path || ''

        client.put path, params?.data, (err, req, res, data) ->
            return callback err if err?
            callback null, data

module.exports = HttpConnector