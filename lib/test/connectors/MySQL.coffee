'use strict'

expect = require 'expect.js'

describe 'the MySQLConnector,', ->

    MySQLConnector = null

    params = null
    connector = null

    beforeEach ->
        delete require.cache[MySQLConnector]
        MySQLConnector = require '../../src/connectors/MySQL'
        params =
            host : 'host'
            poolSize : 1
            timeout : 10000
            user: 'user'
            password: 'password'
            domain: 'databaseName'
            resource: 'tableName'

    describe 'when creating a new instance', ->

        beforeEach ->
            params = null

        it 'should throw an exception if one or more params was not passed', ->

            expect(->
                new MySQLConnector {}
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if host is not useful', ->
            expect(->
                params =
                    host: {}
                    poolSize: 1
                    timeout: 12
                    user: 'test'
                    password: 'test'
                    domain: 'test'
                    resource: 'test'
                (new MySQLConnector(params)).init()
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if domain is not useful', ->
            expect(->
                params =
                    host: 'test'
                    poolSize: 1
                    timeout: 12
                    user: 'test'
                    password: 'test'
                    domain: {}
                    resource: 'test'
                new MySQLConnector params
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if resource is not useful', ->
            expect(->
                params =
                    host: 'test'
                    poolSize: 1
                    timeout: 12
                    user: 'test'
                    password: 'test'
                    domain: 'test'
                    resource: {}
                new MySQLConnector params
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if user is not useful', ->
            expect(->
                params =
                    host: 'test'
                    poolSize: 1
                    timeout: 12
                    user: {}
                    password: 'test'
                    domain: 'test'
                    resource: 'test'
                new MySQLConnector params
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if poolSize is not useful', ->
            expect(->
                params =
                    host: 'test'
                    poolSize: {}
                    timeout: 12
                    user: 'test'
                    password: 'test'
                    domain: 'test'
                    resource: 'test'
                new MySQLConnector params
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should verify if the connection pool was created', ->

            createPoolCalled = false

            params =
                host : 'host'
                poolSize : 1
                timeout : 10000
                user: 'user'
                password: 'password'
                domain: 'databaseName'
                resource: 'tableName'

            expectedParams =
                host: params.host
                database: params.domain
                user: params.user
                password: params.password
                connectionLimit: params.poolSize
                acquireTimeout: params.timeout
                waitForConnections: 0

            deps =
                mysql:
                    createPool: (params) ->
                        expect(params).to.eql expectedParams
                        createPoolCalled = true

            connector = new MySQLConnector params, deps
            expect(connector).to.be.ok()
            expect(connector.pool).to.be.ok()
            expect(createPoolCalled).to.be.ok()

    describe 'when reading an order', ->

        it 'should return an error if the order id is null', (done) ->

            expectedError = 'Invalid id'

            connector = new MySQLConnector params
            connector.readById null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the order id is undefined', (done) ->

            expectedError = 'Invalid id'

            connector = new MySQLConnector params
            connector.readById undefined, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the order id is zero', (done) ->

            expectedError = 'Invalid id'

            connector = new MySQLConnector params
            connector.readById 0, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        # deverá retornar erro ao pegar uma nova conexão do pool de conexões
        it 'should return an error if the connection was unsuccessful', (done) ->

            expectedError = 'Error getConnection'

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback 'Error to get connection'

            connector = new MySQLConnector params, deps
            connector.init params, deps
            connector._execute 'SELECT * FROM sky', [], (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return the query error if it happens', (done) ->

            releaseMethodCalled = no

            expectedError = 'Error Query'

            mockedConnection =
                query: (query, params, callback) ->
                    callback expectedError
                release: ->
                    releaseMethodCalled = yes

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector
            connector.init params, deps

            connector._selectDatabase = (databaseName, connection, callback)->
                callback()

            connector.readById 1, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                expect(releaseMethodCalled).to.be yes
                done()

        it 'should return the found row', (done) ->

            expectedRow =
                reference: 1
                amount: 100

            mockedConnection =
                query: (query, params, callback) ->
                    callback null, expectedRow
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector
            connector.init params, deps
            connector.readById 1, (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).to.eql expectedRow
                done()

        it 'should return a NOT_FOUND error if nothing was found', (done) ->

            expectedRow =
                reference: 1
                amount: 100

            mockedConnection =
                query: (query, params, callback) ->
                    callback()
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector
            connector.init params, deps
            connector.readById 1, (error, response) ->
                expect(error).not.to.be 'NOT FOUND'
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the database selection went wrong', (done) ->

            expectedError = 'Error select database'

            mockedConnection =
                query: (query, params, callback) ->
                    callback()
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector params, deps

            connector._selectDatabase = (databaseName, connection, callback)->
                callback expectedError

            connector.readById 1, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

     describe 'when creating an order', ->

        it 'should return an error if the order data is null', (done) ->

            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.create null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the order data is undefined', (done) ->

            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.create undefined, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the order data is Empty object', (done) ->

            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.create {}, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return the query error if it happens', (done) ->

            expectedError = 'Error Query'

            data =
                id:1

            connector = new MySQLConnector params

            connector._execute = (query, params, callback)->
                callback expectedError

            connector.create data, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return the found rows affected', (done) ->

            expectedResponse = 'Rows Affected:1'

            data =
               id : 101
               reference: 321321
               seq_code_status: 1
               description: "Teste recarga"
               return_url: "www.google.com"
               amount : 201
               payment_type: "credito_a_vista"
               installments: 1

            connector = new MySQLConnector params

            connector._execute = (query, params, callback)->
                callback null, expectedResponse

            connector.create data, (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).to.eql expectedResponse
                done()

        # it 'should pass the expected Query and Params', (done) ->

        #     expectedQuery = 'INSERT INTO tableName SET id=?'
        #     expectedQuery += ',reference=?,seq_code_status=?,description=?,return_url=?'
        #     expectedQuery += ',amount=?,payment_type=?,installments=?'
            
        #     expectedParams = [
        #         101,
        #         321321,
        #         1,
        #         "Teste recarga",
        #         "www.google.com",
        #         201,
        #         "credito_a_vista",
        #         1
        #     ]

        #     data =
        #        id : 101
        #        reference: 321321
        #        seq_code_status: 1
        #        description: "Teste recarga"
        #        return_url: "www.google.com"
        #        amount : 201
        #        payment_type: "credito_a_vista"
        #        installments: 1

        #     connector = new MySQLConnector params

        #     connector._execute = (query, params, callback)->
        #         expect(query).to.eql expectedQuery
        #         expect(params).to.eql expectedParams
        #         done()

        #     connector.create data, ->

    describe 'when reading an order', ->

        it 'should hand the mysql error to the callback', (done) ->

            expectedError = 'Value too large for defined data type'

            mockedConnection =
                query: (query, params, callback) ->
                    callback expectedError
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector
            console.log connector._execute.toString()
            connector.init params, deps
            connector._selectDatabase = (databaseName, connection, callback)->
                callback null, mockedConnection

            connector.read 'SELECT size FROM yo_mama', (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return a NOT FOUND error if nothing was found (obviously)', (done) ->

            mockedConnection =
                query: (query, params, callback) ->
                    callback()
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector params, deps
            connector._selectDatabase = (databaseName, connection, callback)->
                callback null, mockedConnection

            connector.read 'SELECT weight_reduction FROM yo_mama', (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).not.to.be.ok()
                done()

        it 'should return the order found', (done) ->

            expectedOrder =
                this: 'is'
                your: 'order'

            mockedConnection =
                query: (query, params, callback) ->
                    callback null, expectedOrder
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection

            connector = new MySQLConnector params, deps
            connector._selectDatabase = (databaseName, connection, callback)->
                callback null, mockedConnection

            connector.read 'SELECT weight_reduction FROM yo_mama', (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).to.eql expectedOrder
                done()

    describe 'when updating an order', ->

        it 'deve receber um erro se o id for undefined', (done) ->
            expectedError = 'Invalid id'

            connector = new MySQLConnector params
            connector.update undefined, null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o id for null', (done) ->
            expectedError = 'Invalid id'

            connector = new MySQLConnector params
            connector.update null, null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o id for zero', (done) ->
            expectedError = 'Invalid id'

            connector = new MySQLConnector params
            connector.update 0, null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o data for undefined', (done) ->
            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.update '1', undefined, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o data for null', (done) ->
            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.update '1', null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o data for vazio', (done) ->
            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.update '1', {}, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()
        
        it 'deve receber um erro se acontecer algum erro ao efetuar um update', (done) ->
            expectedError = 'Error Query'

            data =
                id:1

            connector = new MySQLConnector params

            connector._execute = (query, params, callback)->
                callback expectedError

            connector.update 1,data, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should pass the expected Query and Params', (done) ->

            id = '12345678901234567890'

            data =
               issuer: "visa"
               payment_type: "credito_a_vista"
               installments: 1

            expectedQuery = 'UPDATE tableName SET issuer=?,payment_type=?,installments=? WHERE id=?'

            expectedParams = [
                data.issuer,
                data.payment_type,
                data.installments,
                id
            ]

            connector = new MySQLConnector params

            connector._execute = (query, params, callback)->
                expect(query).to.eql expectedQuery
                expect(params).to.eql expectedParams
                done()

            connector.update id, data, ->

        it 'deve retornar sucesso se não ocorreu nenhum erro', (done) ->

            data =
               issuer: "visa"
               payment_type: "credito_a_vista"
               installments: 1

            connector = new MySQLConnector params

            expectedRow =
                affected_rows: 1

            connector._execute = (query, params, callback)->
                callback null, expectedRow

            connector.update '123', data, (err, row) ->
                expect(err).not.to.be.ok()
                expect(row).to.be.eql expectedRow
                done()