

'use strict'

expect = require 'expect.js'

describe 'the MySQLConnector,', ->

    MySQLConnector = null

    params = null
    connector = null

    beforeEach ->
        delete require.cache[require.resolve('../../src/connectors/MySQL')]
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

        it 'should throw an exception if one or more params was not passed', ->

            expect(->
                instance = new MySQLConnector {}
                instance.init {}
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if host is empty object', ->
            expect(->
                params.host = {}
                instance = new MySQLConnector
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if host is null', ->
            expect(->
                params.host = null
                instance = new MySQLConnector
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if host is undefined', ->
            expect(->
                params.host = undefined
                instance = new MySQLConnector
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if host is zero', ->
            expect(->
                params.host = 0
                instance = new MySQLConnector
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if host is empty string', ->
            expect(->
                params.host = ''
                instance = new MySQLConnector
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if domain is not useful', ->
            expect(->
                params.domain = {}
                instance = new MySQLConnector
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if resource is not useful', ->
            expect(->
                params.resource = {}
                instance = new MySQLConnector
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if user is not useful', ->
            expect(->
                params.user = {}
                instance = new MySQLConnector
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should throw an exception if poolSize is not useful', ->
            expect(->
                params.poolSize = {}
                instance = new MySQLConnector
            ).to.throwError((e) ->
                expect(e.type).to.be 'Fatal'
                expect(e.name).to.be 'Invalid argument'
                expect(e.message).to.be.ok()
            )

        it 'should verify if the connection pool was created', ->

            createPoolCalled = false

            params =
                host : 'host'
                port : 1111
                poolSize : 1
                timeout : 10000
                user: 'user'
                password: 'password'
                domain: 'databaseName'
                resource: 'tableName'

            expectedParams =
                host: params.host
                port: params.port
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

            instance = new MySQLConnector params, deps

            expect(instance).to.be.ok()
            expect(instance.pool).to.be.ok()
            expect(createPoolCalled).to.be.ok()

        it 'should verify if the connection pool was created with default port', ->

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
                port: 3306
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

            instance = new MySQLConnector params, deps

            expect(instance).to.be.ok()
            expect(instance.pool).to.be.ok()
            expect(createPoolCalled).to.be.ok()

    describe 'when reading a specific order', ->

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

        it 'should return an error if the executing query went wrong', (done) ->

            expectedError = 'Internal Error'

            instance = new MySQLConnector params
            instance._execute = (query, params, callback) ->
                callback expectedError
            instance.readById 1, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return the found row', (done) ->

            expectedRow =
                reference: 1
                amount: 100

            instance = new MySQLConnector params
            instance._execute = (query, params, callback) ->
                callback null, expectedRow
            instance.readById 1, (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).to.eql expectedRow
                done()

        it 'should return a NOT_FOUND error if nothing was found', (done) ->

            expectedError =
                name: 'Not found'
                message: ''
                type: 'Error'

            instance = new MySQLConnector params
            instance._execute = (query, params, callback) ->
                callback()
            instance.readById 1, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

    describe 'when reading an order', ->

        it 'should hand the mysql error to the callback', (done) ->

            expectedError = 'Value too large for defined data type'

            instance = new MySQLConnector params
            instance._execute = (query, params, callback)->
                callback expectedError

            instance.read 'SELECT size FROM yo_mama', (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return the order found', (done) ->

            expectedOrder =
                this: 'is'
                your: 'order'

            instance = new MySQLConnector params
            instance._execute = (query, params, callback)->
                callback null, expectedOrder

            instance.read 'SELECT weight_reduction FROM yo_mama', (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).to.eql expectedOrder
                done()

        it 'should return a NOT FOUND error if nothing was found (obviously)', (done) ->

            instance = new MySQLConnector params
            instance._execute = (query, params, callback)->
                callback()

            instance.read 'SELECT weight_reduction FROM yo_mama', (error, response) ->
                expect(error).not.to.be.ok()
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

            data =
               id : 101
               reference: 321321
               issuer: 'visa'
               auth_token: 'token1'
               description: 'Teste recarga'
               return_url: 'www.google.com'
               amount : 201
               payment_type: 'credito_a_vista'
               installments: 1
               tid: '231345644'

            connector = new MySQLConnector params

            connector._execute = (query, params, callback)->
                callback()

            connector.create data, (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).not.to.be.ok()
                done()

        it 'should pass the expected Query and Params', (done) ->

            expectedQuery = 'INSERT INTO tableName SET '
            expectedQuery += 'id=?,reference=?,issuer=?,auth_token=?,description=?,return_url=?,amount=?,payment_type=?,installments=?,tid=?'

            expectedParams = [
                101,
                321321,
                'visa',
                'token1',
                'Teste recarga',
                'www.google.com',
                201,
                'credito_a_vista',
                1,
                '231345644'
            ]

            data =
                id: 101
                reference: 321321
                issuer: 'visa'
                auth_token: 'token1'
                description: 'Teste recarga'
                return_url: 'www.google.com'
                amount: 201
                payment_type: 'credito_a_vista'
                installments: 1
                tid: '231345644'

            connector = new MySQLConnector params

            connector._execute = (query, params, callback)->
                expect(query).to.eql expectedQuery
                expect(params).to.eql expectedParams
                done()

            connector.create data, ->

    describe 'when creating an multiple orders', ->

        it 'should return an error if the order data is null', (done) ->

            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.multiCreate null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the order data is undefined', (done) ->

            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.multiCreate undefined, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the order data is Empty object', (done) ->

            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.multiCreate {}, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return the query error if it happens', (done) ->

            expectedError = 'Error Query'

            data = [
                {
                    id: 1
                    other_id: 2
                    any_id: 99
                }
            ]

            connector = new MySQLConnector params

            connector._execute = (query, params, callback)->
                callback expectedError

            connector.multiCreate data, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return the found rows affected', (done) ->

            data = [
                {
                    id: 1
                    other_id: 2
                    any_id: 99
                }
            ]

            connector = new MySQLConnector params

            connector._execute = (query, params, callback)->
                callback()

            connector.multiCreate data, (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).not.to.be.ok()
                done()

        it 'should pass the expected Query and Params', (done) ->

            expectedQuery = 'INSERT INTO tableName (id,other_id,any_id) VALUES (?,?,?),(?,?,?),(?,?,?)'

            expectedParams = [10,20,30,15,25,35,25,35,45]

            data = [
                {
                    id       : expectedParams[0]
                    other_id : expectedParams[1]
                    any_id   : expectedParams[2]
                },
                {
                    id       : expectedParams[3]
                    other_id : expectedParams[4]
                    any_id   : expectedParams[5]
                },
                {
                    id       : expectedParams[6]
                    other_id : expectedParams[7]
                    any_id   : expectedParams[8]
                }
            ]

            console.log ''
            connector = new MySQLConnector params

            connector._execute = (query, params, callback)->
                expect(query).to.eql expectedQuery
                expect(params).to.eql expectedParams
                done()

            connector.multiCreate data, ->

    describe 'when deleting', ->

        it 'should pass the expected Query and Params', (done) ->

            expectedQuery = 'DELETE FROM tableName WHERE id=?'

            expectedParams = [
                101
            ]

            data =
                id: 101

            connector = new MySQLConnector params

            connector._execute = (query, params, callback)->
                expect(query).to.eql expectedQuery
                expect(params).to.eql expectedParams
                done()

            connector.delete data, ->

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

    describe 'when updating by field an order', ->

        it 'deve receber um erro se o field for undefined', (done) ->
            expectedError = 'Invalid field'

            connector = new MySQLConnector params
            connector.updateByField undefined, null, null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o field for null', (done) ->
            expectedError = 'Invalid field'

            connector = new MySQLConnector params
            connector.updateByField null, null, null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o field_value for undefined', (done) ->
            expectedError = 'Invalid field_value'

            connector = new MySQLConnector params
            connector.updateByField 'order_id', undefined, null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o field_value for null', (done) ->
            expectedError = 'Invalid field_value'

            connector = new MySQLConnector params
            connector.updateByField 'order_id', null, null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o field_value for zero', (done) ->
            expectedError = 'Invalid field_value'

            connector = new MySQLConnector params
            connector.updateByField 'order_id', 0, null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o data for undefined', (done) ->
            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.updateByField '1', 1, undefined, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o data for null', (done) ->
            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.updateByField '1', 1, null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'deve receber um erro se o data for vazio', (done) ->
            expectedError = 'Invalid data'

            connector = new MySQLConnector params
            connector.updateByField '1', 1, {}, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should pass the expected Query and Params', (done) ->

            id = '12345678901234567890'

            data =
               issuer: "visa"
               payment_type: "credito_a_vista"
               installments: 1

            expectedQuery = 'UPDATE tableName SET issuer=?,payment_type=?,installments=? WHERE order_id=?'

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

            connector.updateByField 'order_id', id, data, ->

        it 'deve receber um erro se acontecer algum problema ao efetuar um update', (done) ->

            expectedError = 'Error Query'

            data =
                id:1

            connector = new MySQLConnector params
            connector._execute = (query, params, callback)->
                callback expectedError

            connector.updateByField 'order_id', 1, data, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

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

            connector.updateByField 'order_id', '123', data, (err, row) ->
                expect(err).not.to.be.ok()
                expect(row).to.be.eql expectedRow
                done()

    describe 'when executing a query', ->

        it 'should return an error if was a get connection problem', (done) ->

            expectedError = 'Database connection failed. Error: my error'

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback 'my error'

            instance = new MySQLConnector params, deps
            instance._execute '', [], (error, response)->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if was a selecting database', (done) ->

            expectedError = 'Error selecting database'

            mockedConnection =
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection
            instance = new MySQLConnector params, deps
            instance._selectDatabase = (databaseName, connection, callback) ->
                callback expectedError
            instance._execute '', [], (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error after selecting database', (done) ->

            expectedError = 'Internal Error'

            mockedConnection =
                query: (query, params, callback) ->
                    callback expectedError
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection
            instance = new MySQLConnector params, deps
            instance._selectDatabase = (databaseName, connection, callback) ->
                callback()
            instance._execute '', [], (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return a expected result if everything was ok', (done) ->

            expectedResponse =
                affected_rows: 1

            mockedConnection =
                query: (query, params, callback) ->
                    callback null, expectedResponse
                release: ->

            deps =
                mysql:
                    createPool: (params) ->
                        getConnection: (callback) ->
                            callback null, mockedConnection
            instance = new MySQLConnector params, deps
            instance._selectDatabase = (databaseName, connection, callback) ->
                callback()
            instance._execute '', [], (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).to.eql expectedResponse
                done()

    describe 'when selecting a database', ->

        it 'should pass the expected Query', (done) ->

            databaseName = 's2Pay'

            expectedQuery = "USE #{databaseName}"

            mockedConnection =
                query: (query, values, callback) ->
                    expect(query).to.eql expectedQuery
                    expect(values).to.eql []
                    done()

            instance = new MySQLConnector params
            instance._selectDatabase databaseName, mockedConnection, ->

    describe 'when changing a tableName', ->

        it 'deve validar se o nome da tabela foi alterada corretamente', ->
            connector = new MySQLConnector params
            connector.changeTable 'secondTableName'
            expect(connector.table).to.eql 'secondTableName'

    describe 'when reading a order with join', ->

        mysqlParams = null
        joinParams = null

        beforeEach ->
            mysqlParams =
                host: 'host'
                poolSize : 1
                timeout : 10000
                user: 'user'
                password: 'password'
                domain: 'databaseName'
                resource: 'table1'

            joinParams =
                table: 'table2'
                condition: 'table1.id = table2.table1_id'
                fields: ['field1','field2']

        it 'should return an error if the order id is null', (done) ->

            expectedError = 'Invalid id'

            connector = new MySQLConnector mysqlParams
            connector.readJoin null, null, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the join table is null', (done) ->

            expectedError = 'Invalid join parameters'

            delete joinParams.table

            connector = new MySQLConnector mysqlParams
            connector.readJoin '123465789', joinParams, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the join condition is null', (done) ->

            expectedError = 'Invalid join parameters'

            delete joinParams.condition

            connector = new MySQLConnector mysqlParams
            connector.readJoin '123465789', joinParams, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error if the join fields is null', (done) ->

            expectedError = 'Invalid join parameters'

            delete joinParams.fields

            connector = new MySQLConnector mysqlParams
            connector.readJoin '123465789', joinParams, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return an error when executing a query', (done) ->

            expectedError = 'Internal error'

            connector = new MySQLConnector mysqlParams
            connector._execute = (query, params, callback) ->
                callback expectedError
            connector.readJoin '123456789', joinParams, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should return a row if was found', (done) ->

            expectedResponse =
                id: '123456789'
                something: 'something'

            connector = new MySQLConnector mysqlParams
            connector._execute = (query, params, callback) ->
                callback null, expectedResponse
            connector.readJoin '123456789', joinParams, (error, response) ->
                expect(error).not.to.be.ok()
                expect(response).to.eql expectedResponse
                done()

        it 'should return an error if the result was not found', (done) ->

            expectedError = 'NOT_FOUND'

            connector = new MySQLConnector mysqlParams
            connector._execute = (query, params, callback) ->
                callback()
            connector.readJoin '123456789', joinParams, (error, response) ->
                expect(error).to.eql expectedError
                expect(response).not.to.be.ok()
                done()

        it 'should validate a final query with all params possibilities', (done) ->

            expectedQuery = "SELECT field1,field2 FROM table1 JOIN table2 ON table1.id = table2.table1_id WHERE table1.id = ? ORDER BY orderField DESC LIMIT 15"
            expectedParams = [123456789]

            joinParams.orderBy = 'orderField DESC'
            joinParams.limit = 15

            inputMessage =
                data:
                    id: 123456789

            connector = new MySQLConnector mysqlParams
            connector._execute = (query, params, callback) ->
                expect(query).to.eql expectedQuery
                expect(params).to.eql expectedParams
                done()

            connector.readJoin inputMessage, joinParams, ->

    describe 'when start a transaction in connection', ->

        it 'should call execute start transaction command', (done) ->

            expected =
                query: 'START TRANSACTION'
                params: []

            connector = new MySQLConnector params
            connector._execute = (query, params, callback) ->
                expect(query).to.eql expected.query
                expect(params).to.eql expected.params
                done()
            connector.start_transaction ->

        it 'should return an error message if the database is out', (done) ->

            expected =
                errorMessage: 'Internal Error'

            connector = new MySQLConnector params
            connector._execute = (query, params, callback) ->
                callback expected
            connector.start_transaction (error, success) ->
                expect(error).to.eql expected
                expect(success).not.to.be.ok()
                done()

    describe 'when a commit transaction in connection', ->

        it 'should call execute commit command', (done) ->

            expected =
                query: 'COMMIT'
                params: []

            connector = new MySQLConnector params
            connector._execute = (query, params, callback) ->
                expect(query).to.eql expected.query
                expect(params).to.eql expected.params
                done()
            connector.commit ->

        it 'should return an error message if the database is out', (done) ->

            expected =
                errorMessage: 'Internal Error'

            connector = new MySQLConnector params
            connector._execute = (query, params, callback) ->
                callback expected
            connector.commit (error, success) ->
                expect(error).to.eql expected
                expect(success).not.to.be.ok()
                done()

    describe 'when a rollback transaction in connection', ->

        it 'should call execute  ->rollback command', (done) ->

            expected =
                query: 'ROLLBACK'
                params: []

            connector = new MySQLConnector params
            connector._execute = (query, params, callback) ->
                expect(query).to.eql expected.query
                expect(params).to.eql expected.params
                done()
            connector.rollback ->

        it 'should return an error message if the database is out', (done) ->

            expected =
                errorMessage: 'Internal Error'

            connector = new MySQLConnector params
            connector._execute = (query, params, callback) ->
                callback expected
            connector.rollback (error, success) ->
                expect(error).to.eql expected
                expect(success).not.to.be.ok()
                done()

    describe 'when a call procedure', ->

        it 'should call procedure method', (done) ->

            expectedError = 'Internal Error'

            connector= new MySQLConnector params
            connector._execute =  (query, params, callback) ->
                done()
            connector.callProcedure 'baixa_pedido', [], ->

        it 'should return an error message if the procedure execution failed',  (done) ->

            expectedError = 'Internal error'

            connector = new MySQLConnector params
            connector._execute = (query, params, callback) ->
                callback expectedError
            connector.callProcedure 'baixa_pedido', [], (error, success)->
                expect(error).to.eql expectedError
                expect(success).not.to.be.ok()
                done()

        it 'should return a procedure results if everything is ok', (done) ->

            expectedMessage = 'ok'

            connector = new MySQLConnector params
            connector._execute = (query, params, callback) ->
                callback null, expectedMessage
            connector.callProcedure 'baixa_pedido', [], (error, success) ->
                expect(error).not.to.be.ok()
                expect(success).to.eql expectedMessage
                done()