###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###

# Dependencies
Exceptions = require './Exceptions'
Rules = require './Rules'
events = require 'events'

class Watcher

    @NAME: 'name'
    @START: 'start'
    @STOP: 'stop'
    @INIT: 'init'
    @TIMEOUT: 'timeout'
    @REGEX_FUNCTION_NAME: /^[a-zA-Z]*$/
    @DEFAULT_TIMEOUT: 10000

    constructor: (params) ->
        @tasks = {}
        @name = '' || params?.name

    _checkArgs: (task, callback) ->
        name = task[Watcher.NAME]
        throw new Exceptions.Error Exceptions.INVALID_ARGUMENT, 'callback' unless Rules.isFunction callback
        return new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.NAME if Rules.isEmpty name
        unless Rules.regex name, Watcher.REGEX_FUNCTION_NAME
            return new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.NAME
        unless Rules.isFunction task[Watcher.START]
            return new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.START
        unless Rules.isFunction task[Watcher.STOP]
            return new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.STOP

    register: (task, callback) ->
        error = @_checkArgs task, callback
        return callback error if error
        obj =
            task: task
            meta:
                isLocked: false
            info:
                createdAt: new Date().toISOString()
                lastError: ''
                lastSuccess: ''
                lastTimeout: ''
            counters:
                error: 0
                success: 0
                timeout: 0
            events: new events.EventEmitter

        obj.events.addListener 'success', ->
            obj.info.lastSuccess = new Date().toISOString()
            obj.counters.success++
            obj.meta.isLocked = false

        obj.events.addListener 'error', ->
            obj.info.lastError = new Date().toISOString()
            obj.counters.error++
            obj.meta.isLocked = false

        obj.events.addListener 'timeout', ->
            obj.info.lastTimeout = new Date().toISOString()
            obj.counters.timeout++
            obj.meta.isLocked = false

        @tasks[task[Watcher.NAME]] = obj

        return task[Watcher.INIT](callback) if task[Watcher.INIT]
        return callback()

    unRegister: (taskName, callback) ->
        task = @tasks[taskName]
        notFoundTask = Rules.isEmpty task
        return callback new Exceptions.Error Exceptions.NOT_FOUND, taskName if notFoundTask
        timeout = @_timeout callback, task.task[Watcher.TIMEOUT]
        cbStop = (err) ->
            timeout = null
            return callback err
        task.task[Watcher.STOP](task.events, cbStop)

    _timeout: (callback, timeout = Watcher.DEFAULT_TIMEOUT) ->
        watch = setTimeout () ->
            return callback new Exceptions.Error Exceptions.TIMEOUT
        , timeout
        return watch

    status: () ->
        return JSON.stringify @tasks

    taskStatus: (taskName) ->
        return JSON.stringify @tasks[taskName]


#    _launchTask: (task) ->
#        task.init?()
#        name = task[EXEC_NAME]
#        interval = task[EXEC_INTERVAL]
#        run = EXEC_RUN
#
#        @tasks++
#
#        task.__failsToWarn = task[FAILS_TO_WARN] || 0
#        task.__failsToError = task[FAILS_TO_ERROR] || 0
#        task.__logEvery = task[LOG_EVERY] || 0
#        task.__logTrigger = 0
#        task.__failCounter = 0
#        task.__successCounter = 0
#        task.__status = 0
#        task.__isLocked = false
#        task.__emiter = new events.EventEmitter
#
#        task.__emiter.addListener 'success', ->
#            task.__successCounter++
#            task.__isLocked = false
#
#        task.__emiter.addListener 'error', ->
#            task.__failCounter++
#            task.__status = 1 if task.__failCounter >= task.__failsToWarn and task.__status is 0
#            task.__status = 2 if task.__failCounter >= task.__failsToError and task.__status is 1
#            task.__isLocked = false
#
#        @_log "Task: [#{name}] was registered. [every = #{interval}]"
#
#        @_timers.push setInterval (@_logger) ->
#            task.__logTrigger++ if !task.__isLocked
#
#            if task.__logTrigger >= task.__logEvery
#                @_logger?.log? "Task: [#{name}] was invoked. [#{task.__logTrigger}]"
#                task.__logTrigger = 0
#
#            unless task.__isLocked
#                task.__isLocked = true
#                task[run](task.__emiter)
#        , interval, @_serverLogger


module.exports = Watcher