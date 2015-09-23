Exceptions = require('../Exceptions')

# The Couchbase DataSource uses the following definition
#
#<DataSourceName>
# type = Couchbase ** must be like this ** <DataSourceType>
# host = ** required <host>
# port = ** required <port>
# bucket = ** required <bucketName>
# n1qlHost: "127.0.0.1" <N1QL query language host>
# n1qlPort: 8093  <N1QL query language port>
#
#ephemeral:
#    type: "Couchbase"
#    host: "127.0.0.1"
#    port: 8091
#    bucket: "ephemeral"
#    n1qlHost: "127.0.0.1"
#    n1qlPort: 8093

class Couchbase

    limbo = null

    constructor: (dataSource) ->
        @_dataSource = dataSource
        @_couchbase = require 'couchbase'
        @n1ql = require('couchbase').N1qlQuery
        @limbo = {}

    # Component initialization
    # Check if the data source specified in the constructor exists
    init: () ->
        throw new Exceptions.IllegalArgument "Datasource not received." unless @_dataSource
        @bucketName = @_dataSource.bucket
        @cluster = new @_couchbase.Cluster "#{@_dataSource.host}:#{@_dataSource.port}"
        # @bucket = @cluster.openBucket @bucketName
        # @bucket.enableN1ql "#{@_dataSource.n1qlHost}:#{@_dataSource.n1qlPort}" if @_dataSource.n1qlPort?
        @limbo._bucket = @cluster.openBucket @bucketName unless @limbo._bucket
        @limbo._bucket.enableN1ql "#{@_dataSource.n1qlHost}:#{@_dataSource.n1qlPort}" if @_dataSource.n1qlPort?
        @limbo._bucket.operationTimeout = 30 * 1000

    # Close the database connection
    destroy: ->
        # @bucket?.disconnect()

module.exports = Couchbase