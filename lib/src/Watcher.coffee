###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###

class Watcher

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