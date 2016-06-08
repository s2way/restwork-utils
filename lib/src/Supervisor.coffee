moment = require 'moment'
Watcher = require './Watcher'
Info = require './SystemInfo'
ElasticSearch = require './connectors/ElasticSearch'

class Supervisor

    name: 'SystemInfo'

    constructor: (config = {}) ->
        console.log "Supervisor starting with pid #{process.pid}"
        @index = config.index or 'microservices'
        @type = config.type or 'server_metrics'
        @url = config.url or '127.0.0.1'
        @port = config.port or 9200
        @interval = config.interval or 2000
        @pid = config.pid or process.pid
        @app = config.app or 'App'
        watcher = new Watcher log: false
        console.log "Appending Supervisor to pid #{@pid}..."
        watcher.register @, (err) =>
            console.log err if err?
            console.log "#{@app} #{@name} at pid #{@pid} registered." unless err?

    run: (emitter) ->
        info = new Info @app, @pid
        es = new ElasticSearch
        stats =
            index: @index
            type: @type
            data: info.gather()
        source = host: @url, port: @port
        es.save source, stats, (e, s) ->
            console.log e
            emitter.emit 'error' if e
            emitter.emit 'success'
        es = null

    stop: ->

module.exports = Supervisor