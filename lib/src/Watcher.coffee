###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###

# Dependencies
Exceptions = require './Exceptions'
Rules = require './Rules'
events = require 'events'
http = require 'http'

class Watcher

    @NAME: 'name'
    @RUN: 'run'
    @STOP: 'stop'
    @INIT: 'init'
    @INTERVAL: 'interval'
    @TIMEOUT: 'timeout'
    @REGEX_FUNCTION_NAME: /^[a-zA-Z]*$/
    @DEFAULT_TIMEOUT: 10000

    constructor: (params) ->
        @tasks = {}
        @runners = {}
        @observers = {}
        @stop = false
        @name = '' || params?.name

    _checkArgs: (task, callback) ->
        name = task[Watcher.NAME]
        throw new Exceptions.Error Exceptions.INVALID_ARGUMENT, 'callback' unless Rules.isFunction callback
        return new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.NAME if Rules.isEmpty name
        unless Rules.regex name, Watcher.REGEX_FUNCTION_NAME
            return new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.NAME
        unless Rules.isFunction task[Watcher.RUN]
            return new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.RUN
        unless Rules.isFunction task[Watcher.STOP]
            return new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.STOP
        if not Rules.isInteger task[Watcher.INTERVAL] or task[Watcher.INTERVAL] <= 0
            return new Exceptions.Error Exceptions.INVALID_ARGUMENT, Watcher.INTERVAL

    register: (task, callback) ->
        error = @_checkArgs task, callback
        return callback error if error
        name = task[Watcher.NAME]
        start = new Date().toISOString()
        obj =
            task: task
            meta:
                isLocked: false
            info:
                createdAt: start
                lastError: null
                lastSuccess: null
                lastTimeout: null
                lastWatchDog: start
                lastWatchDogCheck: start
            counters:
                error: 0
                success: 0
                timeout: 0
                fails: 0
            events: new events.EventEmitter

        # TODO: implement a function to call on task object when timeout occurred
        cbWatchFail = () ->
            obj.counters.fails++ if obj.info.lastWatchDogCheck.toString() is obj.info.lastWatchDog.toString()
            obj.info.lastWatchDogCheck = obj.info.lastWatchDog

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

        obj.events.addListener 'watchdog', ->
            obj.info.lastWatchDog = new Date().toISOString()

        @tasks[name] = obj
        @observers[name] = setInterval cbWatchFail, task[Watcher.TIMEOUT]

        @_launchTask obj

        return task[Watcher.INIT](callback) if task[Watcher.INIT]
        return callback()

    unRegister: (taskName, callback) ->
        task = @tasks[taskName]
        notFoundTask = Rules.isEmpty task
        return callback new Exceptions.Error Exceptions.NOT_FOUND, taskName if notFoundTask
        timeout = @_timeout callback, task.task[Watcher.TIMEOUT]
        cbStop = (err) =>
            clearTimeout timeout
            @_removeTask taskName unless err
            return callback err
        task.task[Watcher.STOP](task.events, cbStop)

    _removeTask: (taskName) ->
        @tasks[taskName].events.removeAllListeners()
        delete @tasks[taskName]
        clearInterval @runners[taskName]
        delete @runners[taskName]
        clearInterval @observers[taskName]
        delete @observers[taskName]

    _timeout: (callback, timeout = Watcher.DEFAULT_TIMEOUT) ->
        watch = setTimeout () ->
            return callback new Exceptions.Error Exceptions.TIMEOUT
        , timeout
        return watch

    status: () ->
        return JSON.stringify @tasks

    taskStatus: (taskName) ->
        return JSON.stringify @tasks[taskName]

    _launchTask: (taskObj) ->
        name = taskObj.task[Watcher.NAME]
        interval = taskObj.task[Watcher.INTERVAL]
        # TODO: log info "Task: [#{name}] was registered. [every = #{interval}]"

        @runners[name] = setInterval (taskObj) ->
            unless taskObj.meta.isLocked
                taskObj.meta.isLocked = true
                taskObj.task[Watcher.RUN](taskObj.events)
                console.log "Task: [#{taskObj.task[Watcher.NAME]}] trying to invoke. "
            else
                console.log "Task: [#{taskObj.task[Watcher.NAME]}] blocked. "
        , taskObj.task[Watcher.INTERVAL], taskObj

module.exports = Watcher