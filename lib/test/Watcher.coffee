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
    badTaskName = '{]error[}'
    instance = null
    defaultParams =
        name: expectedName


    it 'sould be created with the specified name and interval', ->
        instance = new Watcher defaultParams
        expect(instance.name).to.be expectedName

    describe 'register()', ->

        beforeEach ->
            instance = new Watcher defaultParams

        it 'should add a new task', ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.START] = ->
            task[Watcher.STOP] = ->
            instance.register task
            expect(instance.tasks[task[Watcher.NAME]].task[Watcher.NAME]).to.be task.name

        it 'should throw an error if the start property it is not a function', ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.START] = false
            task[Watcher.STOP] = ->
            expect( ->
                instance.register task
            ).to.throwError((e) ->
                expect(e.name).to.be Exceptions.INVALID_ARGUMENT
            )

        it 'should throw an error if the stop property it is not a function', ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.START] = ->
            task[Watcher.STOP] = false
            expect( ->
                instance.register task
            ).to.throwError((e) ->
                expect(e.name).to.be Exceptions.INVALID_ARGUMENT
            )

        it 'should throw an error if the name property it is not a valid string', ->
            task = {}
            task[Watcher.NAME] = badTaskName
            task[Watcher.START] = ->
            task[Watcher.STOP] = ->
            expect( ->
                instance.register task
            ).to.throwError((e) ->
                expect(e.name).to.be Exceptions.INVALID_ARGUMENT
            )

    describe 'unRegister()', ->

        beforeEach ->
            instance = new Watcher defaultParams

        it 'should return true if the task was removed', (done) ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.START] = ->
            task[Watcher.STOP] = ->
            instance.register task
            callback = (err) ->
                expect(err).not.be.ok()
                done()
            instance.unRegister task, callback

        it 'should return error if the task was not be found', (done) ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.START] = ->
            task[Watcher.STOP] = ->
            callback = (err) ->
                expect(err).to.be.ok()
                done()
            instance.unRegister task, callback

        it 'should return error if while trying to stop the task a timeout has occurred', (done) ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.START] = ->
            task[Watcher.STOP] = ->
            instance.register task
            callback = (err) ->
                expect(err).to.be.ok()
                done()
            instance.unRegister task, callback

    describe 'verify()', ->

        beforeEach ->
            instance = new Watcher defaultParams

        it 'should check and log the status of a task', ->
            task = {}
            task[Watcher.NAME] = goodTaskName
            task[Watcher.START] = ->
            task[Watcher.STOP] = ->
            instance.register task

            expect(instance.tasks[Watcher.LAST_RUN]).to.be.ok()
            expect(instance.tasks[Watcher.COUNT]).to.be.ok()
            expect(instance.tasks[Watcher.FAIL]).to.be.ok()
