'use strict'

HttpConnector = require '../../src/connectors/Http'
expect = require 'expect.js'

describe 'the HttpConnector,', ->

    describe 'when the get method is called', ->

        it 'should call createJSONClient if type is JSON', (done) ->

            expectedOptionsUrl =
                url: 'any_url'

            class Restify
                @createJsonClient: (optionsUrl) ->
                    expect(optionsUrl).to.eql expectedOptionsUrl
                    done()
                    mockGet =
                        get: ->

            deps =
                restify: Restify

            params =
                type: 'json'
                url: expectedOptionsUrl.url

            instance = new HttpConnector deps
            instance.get params, ->

        it 'should call createStringClient if type was not passed', (done) ->

            expectedOptionsUrl =
                url: 'any_url'

            class Restify
                @createStringClient: (optionsUrl) ->
                    expect(optionsUrl).to.eql expectedOptionsUrl
                    done()
                    mockGet =
                        get: ->

            deps =
                restify: Restify

            params =
                url: expectedOptionsUrl.url

            instance = new HttpConnector deps
            instance.get params, ->

        it 'should return an error if there was an erro in the request', (done) ->

            expectedError = 'Internal Error'

            class Restify
                @createJsonClient: (optionsUrl) ->
                    mockGet =
                        get: (options, callback) ->
                            callback expectedError

            deps =
                restify: Restify

            params =
                type: 'json'
                url: 'any_url'

            instance = new HttpConnector deps
            instance.get params, (error, success) ->
                expect(error).to.eql expectedError
                expect(success).not.to.be.ok()
                done()

        it 'return the response from the request', (done) ->

            expectedResponse = 'Any Response'
            expectedOptionsUrl =
                url: 'any_url'
            expectedOptionsGet =
                path: ''
                headers:
                    Requester: 'DATAHUB'

            class Restify
                @createJsonClient: (optionsUrl) ->
                    mockGet =
                        get: (options, callback) ->
                            expect(options).to.eql expectedOptionsGet
                            callback null, null, null, expectedResponse

            deps =
                restify: Restify

            params =
                type: 'json'
                url: 'any_url'
                headers:
                    Requester: 'DATAHUB'

            instance = new HttpConnector deps
            instance.get params, (error, success) ->
                expect(error).not.to.be.ok()
                expect(success).to.eql expectedResponse
                done()

    describe 'when the post method is called', (done) ->

        it 'should instantiate restify http client with the passed url', (done) ->

            expectedUrl = 'http://localhost:1234'
            receivedUrl = null

            class Restify
                @createStringClient: (options)->
                    receivedUrl = options.url
                    mockPost =
                        post: ->

            deps =
                restify: Restify

            params =
                url: expectedUrl

            instance = new HttpConnector deps
            instance.post params, ->
            expect(receivedUrl).to.eql expectedUrl
            done()

        it 'should call post with the right params', ->

            expectedPath = '/'
            receivedPath = null
            expectedData =
                message: 'Test data'
            receivedData = null

            class Restify
                @createStringClient: (options)->
                    client =
                        post: (path, object, callback) ->
                            receivedPath = path
                            receivedData = object

            deps =
                restify: Restify

            params =
                url: ''
                path: expectedPath
                data: expectedData

            instance = new HttpConnector deps
            instance.post params, ->
            expect(receivedPath).to.eql expectedPath
            expect(receivedData).to.eql expectedData

        it 'should return an error if there was an error in the request', (done) ->

            expectedError =
                message: 'Any error'

            class Restify
                @createStringClient: (options)->
                    client =
                        post: (path, object, callback) ->
                            callback expectedError

            deps =
                restify: Restify

            params =
                url: ''
                path: '/'
                data: {}

            instance = new HttpConnector deps
            instance.post params, (error, success)->
                expect(error).to.eql expectedError
                expect(success).not.to.be.ok()
                done()

        it 'should return the response from the request', (done) ->

            expectedResponse =
                message: 'Any response'

            expectedOptionsConstrutor =
                url: ''
                headers:
                    Requester: 'DATAHUB'

            expected =
                path: '/'
                data: {}

            class Restify
                @createStringClient: (options)->
                    expect(options).to.eql expectedOptionsConstrutor
                    client =
                        post: (path, data, callback) ->
                            expect(path).to.eql expected.path
                            expect(data).to.eql expected.data
                            callback null, null, null, expectedResponse

            deps =
                restify: Restify

            params =
                url: ''
                path: '/'
                data: {}
                headers:
                    Requester: 'DATAHUB'

            instance = new HttpConnector deps
            instance.post params, (error, success)->
                expect(error).not.to.be.ok()
                expect(success).to.eql expectedResponse
                done()

    describe 'when the put method is called', (done) ->

        it 'should instantiate restify http client with the passed url', (done) ->

            expectedUrl = 'http://localhost:1234'
            receivedUrl = null

            class Restify
                @createStringClient: (options)->
                    receivedUrl = options.url
                    mockPost =
                        put: ->

            deps =
                restify: Restify

            params =
                url: expectedUrl

            instance = new HttpConnector deps
            instance.put params, ->
            expect(receivedUrl).to.eql expectedUrl
            done()

        it 'should call put with the right params', ->

            expectedPath = '/'
            receivedPath = null
            expectedData =
                message: 'Test data'
            receivedData = null

            class Restify
                @createStringClient: (options)->
                    client =
                        put: (path, object, callback) ->
                            receivedPath = path
                            receivedData = object

            deps =
                restify: Restify

            params =
                url: ''
                path: expectedPath
                data: expectedData

            instance = new HttpConnector deps
            instance.put params, ->
            expect(receivedPath).to.eql expectedPath
            expect(receivedData).to.eql expectedData

        it 'should return an error if there was an error in the request', (done) ->

            expectedError =
                message: 'Any error'

            class Restify
                @createStringClient: (options)->
                    client =
                        put: (path, object, callback) ->
                            callback expectedError

            deps =
                restify: Restify

            params =
                url: ''
                path: '/'
                data: {}

            instance = new HttpConnector deps
            instance.put params, (error, success)->
                expect(error).to.eql expectedError
                expect(success).not.to.be.ok()
                done()

        it 'should return the response from the request', (done) ->

            expectedResponse =
                message: 'Any response'

            expectedOptionsConstrutor =
                url: ''
                headers:
                    Requester: 'DATAHUB'

            expected =
                path: '/'
                data: {}

            class Restify
                @createStringClient: (options)->
                    expect(options).to.eql expectedOptionsConstrutor
                    client =
                        put: (path, data, callback) ->
                            expect(path).to.eql expected.path
                            expect(data).to.eql expected.data
                            callback null, null, null, expectedResponse

            deps =
                restify: Restify

            params =
                url: ''
                path: '/'
                data: {}
                headers:
                    Requester: 'DATAHUB'

            instance = new HttpConnector deps
            instance.put params, (error, success)->
                expect(error).not.to.be.ok()
                expect(success).to.eql expectedResponse
                done()
