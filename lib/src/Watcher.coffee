###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###

# Dependencies
Exceptions = require './Exceptions'
Rules = require './Rules'

class Watcher

    @NAME: 'name'
    @START: 'start'
    @STOP: 'stop'
    @REGEX_FUNCTION_NAME: /^[a-zA-Z]*$/

    constructor: (params) ->
        @tasks = {}
        @name = '' || params?.name

    _checkTask: (task) ->
        if (Rules.isEmpty task[Watcher.NAME] or not Rules.regex task[Watcher.NAME], Watcher.REGEX_FUNCTION_NAME)
            throw new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.NAME
        throw new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.START unless Rules.isFunction task[Watcher.START]
        throw new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.STOP unless Rules.isFunction task[Watcher.STOP]

    register: (task) ->
        @_checkTask task
        obj =
            task: task
            meta:
                createdAt: new Date().toISOString()
                lastRun: ''
                errors: 0
                timeouts: 0

        @tasks[task[Watcher.NAME]] = obj

    _launchTask: (task) ->
        task.init?()
        name = task[EXEC_NAME]
        interval = task[EXEC_INTERVAL]
        run = EXEC_RUN

        @tasks++

        task.__failsToWarn = task[FAILS_TO_WARN] || 0
        task.__failsToError = task[FAILS_TO_ERROR] || 0
        task.__logEvery = task[LOG_EVERY] || 0
        task.__logTrigger = 0
        task.__failCounter = 0
        task.__successCounter = 0
        task.__status = 0
        task.__isLocked = false
        task.__emiter = new events.EventEmitter

        task.__emiter.addListener 'success', ->
            task.__successCounter++
            task.__isLocked = false

        task.__emiter.addListener 'error', ->
            task.__failCounter++
            task.__status = 1 if task.__failCounter >= task.__failsToWarn and task.__status is 0
            task.__status = 2 if task.__failCounter >= task.__failsToError and task.__status is 1
            task.__isLocked = false

        @_log "Task: [#{name}] was registered. [every = #{interval}]"

        @_timers.push setInterval (@_logger) ->
            task.__logTrigger++ if !task.__isLocked

            if task.__logTrigger >= task.__logEvery
                @_logger?.log? "Task: [#{name}] was invoked. [#{task.__logTrigger}]"
                task.__logTrigger = 0

            unless task.__isLocked
                task.__isLocked = true
                task[run](task.__emiter)
        , interval, @_serverLogger


module.exports = Watcher