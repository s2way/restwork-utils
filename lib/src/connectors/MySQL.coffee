'use strict'

# TIU DÛ:
  # - Exportar QueryBuilder
  # - Esta classe deve ser static (instancia apenas uma vez)

class MySQLConnector

    @HOST: 'host'
    @POOL_SIZE: 'poolSize'
    @TIMEOUT: 'timeout'
    @USER: 'user'
    @PASSWORD: 'password'
    @DATABASE: 'domain'
    @TABLE: 'resource'
    @DEFAULT_TIMEOUT: 10000

    constructor: (params, container) ->

        @rules = container?.Rules || require('./../../Main').Rules
        @Exceptions = container?.Exceptions || require('./../../Main').Exceptions

        @_checkArg params, 'params'

        @mysql = container?.mysql || require 'mysql'

        host = params[MySQLConnector.HOST] || null
        poolSize = params[MySQLConnector.POOL_SIZE] || null
        timeout = params[MySQLConnector.TIMEOUT] || MySQLConnector.DEFAULT_TIMEOUT
        user = params[MySQLConnector.USER] || null
        password = params[MySQLConnector.PASSWORD] || ''
        @database = params[MySQLConnector.DATABASE] || null
        @table = params[MySQLConnector.TABLE] || null

        @_checkArg host, MySQLConnector.HOST
        @_checkArg user, MySQLConnector.USER
        @_checkArg poolSize, MySQLConnector.POOL_SIZE
        @_checkArg @database, MySQLConnector.DATABASE
        @_checkArg @table, MySQLConnector.TABLE

        poolParams =
            host: host
            database: @database
            user: user
            password: password
            connectionLimit: poolSize
            acquireTimeout: timeout
            waitForConnections: 0

        @pool = @mysql.createPool poolParams

    readById: (id, callback) ->
        return callback 'Invalid id' if !@rules.isUseful(id) or @rules.isZero id
        @_execute "SELECT * FROM #{@table} WHERE id = ?", [id], (err, row) =>
            return callback err if err?
            return callback null, row if @rules.isUseful(row)
            return callback new @Exceptions.Error @Exceptions.NOT_FOUND

    read: (query, callback) ->
        @_execute query, [], (err, row) =>
            return callback err if err?
            return callback null, row if @rules.isUseful(row)
            return callback new @Exceptions.Error @Exceptions.NOT_FOUND

    create: (data, callback) ->
        return callback 'Invalid data' if !@rules.isUseful(data)
        fields = ''
        values = []
        for key, value of data
            fields += "#{key}=?,"
            values.push value
        fields = fields.substr 0,fields.length-1

        @_execute "INSERT INTO #{@table} SET #{fields}", values, (err, row) ->
            return callback err if err?
            return callback null, row

    update:(id, data, callback) ->
        return callback 'Invalid id' if !@rules.isUseful(id) or @rules.isZero id
        return callback 'Invalid data' if !@rules.isUseful(data)

        fields = ''
        values = []

        for key, value of data
            fields += "#{key}=?,"
            values.push value

        fields = fields.substr 0,fields.length-1
        values.push id

        @_execute "UPDATE #{@table} SET #{fields} WHERE id=?", values, (err, row) ->
            return callback err if err?
            return callback null, row

    _checkArg: (arg, name) ->
        if !@rules.isUseful arg
            throw new @Exceptions.Fatal @Exceptions.INVALID_ARGUMENT, "Parameter #{name} is invalid"

    _execute: (query, params, callback) ->
        @pool.getConnection (err, connection) =>
            return callback 'Error getConnection' if err?
            @_selectDatabase "#{@database}", connection, (err) ->
                if err?
                    connection.release()
                    return callback 'Error select database' if err?
                connection.query query, params, (err, row) ->
                    connection.release()
                    callback err, row

    _selectDatabase: (databaseName, connection, callback) ->
        connection.query "USE #{databaseName}", [], callback

    changeTable: (tableName) ->
        @table = tableName
    # createMany
    # readMany
    # update
    # updateMany
    # delete
    # deleteMany


module.exports = MySQLConnector