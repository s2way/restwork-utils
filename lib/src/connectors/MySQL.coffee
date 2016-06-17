'use strict'

class MySQLConnector

    @HOST: 'host'
    @PORT: 'port'
    @POOL_SIZE: 'poolSize'
    @TIMEOUT: 'timeout'
    @USER: 'user'
    @PASSWORD: 'password'
    @DATABASE: 'domain'
    @TABLE: 'resource'
    @DEFAULT_TIMEOUT: 10000

    instance = null

    constructor: (params, container) ->
        return instance if instance?
        @init params, container
        instance = @

    init: (params, container) ->

        @rules = container?.Rules || require('./../../Main').Rules
        @Exceptions = container?.Exceptions || require('./../../Main').Exceptions

        @_checkArg params, 'params'

        @mysql = container?.mysql || require 'mysql'

        host = params[MySQLConnector.HOST] || null
        port = params[MySQLConnector.PORT] || 3306
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

        poolParams =
            host: host
            port: port
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
            return callback()

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

    # multi data in one insert command
    multiCreate: (listData, callback) ->
        return callback 'Invalid data' if !@rules.isUseful(listData)
        isExtractFields = true
        fields = ''
        values = []
        queryValues = ''

        listData.map (data) ->
            queryValues += '('
            for key, value of data

                # Extrai os fields apenas na primeira vez
                fields += "#{key}," if isExtractFields
                values.push value
                queryValues += '?,'

            isExtractFields = false
            # Remove última vírgula da quantidade de fields
            queryValues = queryValues.substr 0,queryValues.length-1
            queryValues += '),'

        # Remove última vírgula da quantidade de rows
        queryValues = queryValues.substr 0,queryValues.length-1
        fields = fields.substr 0,fields.length-1

        @_execute "INSERT INTO #{@table} (#{fields}) VALUES #{queryValues}", values, (err, row) ->
            return callback err if err?
            return callback null, row

    bulkCreate: (query, callback) ->
        @_execute query, [], (err, row) =>
            return callback err if err?
            return callback null, row if @rules.isUseful(row)
            return callback()

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

    updateByField:(field, field_value, data, callback) ->
        return callback 'Invalid field' if !@rules.isUseful(field)
        return callback 'Invalid field_value' if !@rules.isUseful(field_value) or @rules.isZero field_value
        return callback 'Invalid data' if !@rules.isUseful(data)

        fields = ''
        values = []

        for key, value of data
            fields += "#{key}=?,"
            values.push value

        fields = fields.substr 0,fields.length-1
        values.push field_value

        query = "UPDATE #{@table} SET #{fields} WHERE #{field}=?"
        @_execute "UPDATE #{@table} SET #{fields} WHERE #{field}=?", values, (err, row) ->
            return callback err if err?
            return callback null, row

    _checkArg: (arg, name) ->
        if !@rules.isUseful arg
            throw new @Exceptions.Fatal @Exceptions.INVALID_ARGUMENT, "Parameter #{name} is invalid"

    _execute: (query, params, callback) ->
        @pool.getConnection (err, connection) =>
            if err?
                return callback "Database connection failed. Error: #{err}" if err?
            @_selectDatabase "#{@database}", connection, (err) ->
                if err?
                    connection.release()
                    return callback 'Error selecting database' if err?
                connection.query query, params, (err, row) ->
                    connection.release()
                    callback err, row

    _selectDatabase: (databaseName, connection, callback) ->
        connection.query "USE #{databaseName}", [], callback

    changeTable: (tableName) ->
        @table = tableName

    readJoin: (orderIdentifier, params, callback) ->
        orderSearch = null
        fieldSearch = null

        if orderIdentifier?.data?.id?
            orderSearch = orderIdentifier.data.id
            fieldSearch = 'id'
        else if orderIdentifier?.data?.reference?
            orderSearch = orderIdentifier.data.reference
            fieldSearch = 'reference'

        return callback 'Invalid id' if !@rules.isUseful(orderIdentifier) or @rules.isZero orderIdentifier

        joinTable = params?.table || null
        condition = params?.condition || null
        fields = params?.fields || null

        if !@rules.isUseful(joinTable) or !@rules.isUseful(condition) or !@rules.isUseful(fields)
            return callback 'Invalid join parameters'

        if params?.orderBy
            orderBy =  "ORDER BY #{params.orderBy}"
        if params?.limit
            limit = "LIMIT #{params.limit}"

        selectFields = ''

        for key in fields
            selectFields += "#{key},"

        selectFields = selectFields.substring(0, selectFields.length-1)

        query = "SELECT #{selectFields} FROM #{@table} JOIN #{joinTable} ON #{condition} WHERE #{@table}.#{fieldSearch} = ? #{orderBy} #{limit}"

        @_execute query, [orderSearch], (err, row) =>
            return callback err if err?
            return callback null, row if @rules.isUseful(row)
            return callback 'NOT_FOUND'

    delete: (data, callback) ->
        return callback 'Invalid data' if !@rules.isUseful(data)
        fields = ''
        values = []
        for key, value of data
            fields += "#{key}=?,"
            values.push value
        fields = fields.substr 0,fields.length-1

        @_execute "DELETE FROM #{@table} WHERE #{fields}", values, (err, row) ->
            return callback err if err?
            return callback null, row

    start_transaction: (callback) ->
        @_execute "START TRANSACTION", [], (err, row) ->
            return callback err if err?
            return callback null, row

    commit: (callback) ->
        @_execute "COMMIT", [], (err, row) ->
            return callback err if err?
            return callback null, row

    rollback: (callback) ->
        @_execute "ROLLBACK", [], (err, row) ->
            return callback err if err?
            return callback null, row

    callProcedure: (name, data, callback) ->

        fields = ''
        for key, value of data
            fields += "#{value},"
        fields = fields.substr 0,fields.length-1

        query = "CALL #{name} (#{fields})"

        @_execute query, [], (error, success) ->
            return callback error if error?
            callback null, success

    # createMany
    # readMany
    # update
    # updateMany
    # deleteMany


module.exports = MySQLConnector