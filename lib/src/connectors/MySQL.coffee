'use strict'

# TIU DÛ:
  # - Exportar QueryBuilder
  # - Esta classe deve ser static (instancia apenas uma vez)

class MySQLConnector

    @MSG_INVALID_ARGUMENT = "Parameter #{name} is invalid"

    constructor: (params, container) ->

        @rules = container?.Rules || require('./../../Main').Rules
        Exceptions = container?.Exceptions || require('./../../Main').Exceptions

        @_checkArg params, 'params'

        @mysql = container?.mysql || require 'mysql'

        host = params?.host || null
        poolSize = params?.poolSize || null
        timeout = params?.timeout || 10000
        user = params?.user || null
        password = params?.password || ''
        @database = params?.domain || null
        @table = params?.resource || null

        @_checkArg host, 'host'
        @_checkArg user, 'user'
        @_checkArg poolSize, 'poolSize'
        @_checkArg @database, 'domain'
        @_checkArg @table, 'resource'

        poolParams =
            host: host
            database: @database
            user: user
            password: password
            connectionLimit: poolSize
            acquireTimeout: timeout
            waitForConnections: 0

        @pool = @mysql.createPool poolParams

    read: (id, callback) ->
        return callback 'Invalid id' if !@rules.isUseful(id) or @rules.isZero id
        @_execute "SELECT * FROM #{@table} WHERE id = ?", [id], (err, row) =>
            return callback err if err?
            return callback null, row if @rules.isUseful(row)
            return callback new Exceptions.Error Exceptions.NOT_FOUND

    _checkArg: (arg, name) ->
        if !@rules.isUseful arg
            throw new exceptions.Fatal exceptions.INVALID_ARGUMENT, MySQLConnector.MSG_INVALID_ARGUMENT

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

    # createMany
    # readMany
    # update
    # updateMany
    # delete
    # deleteMany


module.exports = MySQLConnector