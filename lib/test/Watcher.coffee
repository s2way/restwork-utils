###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###
# Dependencies
expect = require 'expect.js'
Watcher = require './../src/Watcher'
Exceptions = require './../src/Exceptions'

describe 'Watcher', ->
    expectedName = 'myGroupOfTasks'
    goodTaskName = 'myTask'
    goodTaskName2 = 'yourTask'
    badTaskName = '{]error[}'
    instance = null
    defaultParams =
        name: expectedName
    cbOk = (err) ->
        expect(err).not.to.be.ok()

    it 'should be created with the specified name and interval', ->
        instance = new Watcher defaultParams
        expect(instance.name).to.be expectedName

    describe 'register()', ->

        beforeEach ->
            instance = new Watcher defaultParams

        it 'should throw an error if the callback is not a function', ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.INTERVAL] = 1000
            task[Watcher.RUN] = ->
            task[Watcher.STOP] = ->
            expect( ->
                instance.register task
            ).to.throwError((e) ->
                expect(e.name).to.be Exceptions.INVALID_ARGUMENT
            )

        it 'should add a new task', (done) ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.INTERVAL] = 1000
            task[Watcher.RUN] = ->
            task[Watcher.STOP] = ->
            instance.register task, (err) ->
                cbOk err
                done()

        it 'should return an error if the run property it is not a function', (done) ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.INTERVAL] = 1000
            task[Watcher.RUN] = false
            task[Watcher.STOP] = ->
            instance.register task, (err) ->
                expect(err.name).to.be Exceptions.INVALID_ARGUMENT
                done()

        it 'should throw an error if the stop property it is not a function', (done) ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.INTERVAL] = 1000
            task[Watcher.RUN] = ->
            task[Watcher.STOP] = false
            instance.register task, (err) ->
                expect(err.name).to.be Exceptions.INVALID_ARGUMENT
                done()

        it 'should throw an error if the interval property it is not an integer', (done) ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.INTERVAL] = 'error'
            task[Watcher.RUN] = ->
            task[Watcher.STOP] = false
            instance.register task, (err) ->
                expect(err.name).to.be Exceptions.INVALID_ARGUMENT
                done()

        it 'should throw an error if the name property it is not a valid string', (done) ->
            task = {}
            task[Watcher.NAME] = badTaskName
            task[Watcher.INTERVAL] = 1000
            task[Watcher.RUN] = ->
            task[Watcher.STOP] = ->
            instance.register task, (err) ->
                expect(err.name).to.be Exceptions.INVALID_ARGUMENT
                done()

    describe 'unRegister()', ->

        beforeEach ->
            instance = new Watcher defaultParams

        it 'should return true if the task was removed', (done) ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.INTERVAL] = 1000
            task[Watcher.RUN] = ->
            task[Watcher.STOP] = (emiter, next) ->
                next()

            instance.register task, (err) ->
                expect(err).not.to.be.ok()
                instance.unRegister goodTaskName, (err) ->
                    cbOk err
                    expect(instance.status()).to.be '{}'
                    done()

        it 'should return error if the task was not be found', (done) ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.INTERVAL] = 1000
            task[Watcher.RUN] = ->
            task[Watcher.STOP] = (emiter, next) ->
                next()

            instance.unRegister goodTaskName, (err) ->
                expect(err.name).to.be Exceptions.NOT_FOUND
                done()

        it 'should return error if while trying to stop the task a timeout has occurred', (done) ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.INTERVAL] = 1000
            task[Watcher.RUN] = ->
            task[Watcher.TIMEOUT] = 1
            task[Watcher.STOP] = (emiter, next) ->

            instance.register task, (err) ->
                expect(err).not.to.be.ok()
                instance.unRegister goodTaskName, (err) ->
                    expect(err.name).to.be Exceptions.TIMEOUT
                    done()

    describe 'status()', ->

        beforeEach ->
        instance = new Watcher defaultParams

        it 'should return the all data about the tasks', ->
            task1 = {}
            task1[Watcher.NAME] = goodTaskName
            task1[Watcher.INTERVAL] = 1000
            task1[Watcher.RUN] = ->
            task1[Watcher.STOP] = (emiter, next) ->
                next()
            instance.register task1, (err) ->
                expect(err).not.to.be.ok()
            task2 = {}
            task2[Watcher.NAME] = goodTaskName2
            task2[Watcher.INTERVAL] = 1000
            task2[Watcher.RUN] = ->
            task2[Watcher.STOP] = (emiter, next) ->
                next()
            instance.register task2, (err) ->
                expect(err).not.to.be.ok()

            expect(instance.status().indexOf goodTaskName).to.be.ok()

    describe 'taskStatus()', ->

        beforeEach ->
        instance = new Watcher defaultParams

        it 'should return the all data about the task or undefined if was not found', ->
            task1 = {}
            task1[Watcher.NAME] = goodTaskName
            task1[Watcher.INTERVAL] = 1000
            task1[Watcher.RUN] = ->
            task1[Watcher.STOP] = (emiter, next) ->
                next()
            instance.register task1, (err) ->
                expect(err).not.to.be.ok()
            task2 = {}
            task2[Watcher.NAME] = goodTaskName2
            task2[Watcher.INTERVAL] = 1000
            task2[Watcher.RUN] = ->
            task2[Watcher.STOP] = (emiter, next) ->
                next()
            instance.register task2, (err) ->
                expect(err).not.to.be.ok()

            expect(instance.taskStatus(goodTaskName).indexOf goodTaskName).to.be.ok()
            expect(instance.taskStatus('badTaskName')).not.to.be.ok()