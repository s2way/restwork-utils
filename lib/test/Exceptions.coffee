Exceptions = require './../src/Exceptions'
expect = require 'expect.js'

describe 'Exceptions', ->

    it 'should throw an exception with stack when type is fatal', ->
        expect(->
            throw new Exceptions.Fatal Exceptions.INVALID_ARGUMENT
        ).to.throwError((e) ->
            expect(e.name).to.be Exceptions.INVALID_ARGUMENT
            expect(e.type).to.be Exceptions.TYPE_FATAL
            expect(e.stack).to.be.ok()
        )

    it 'should throw an exception without stack when type is error', ->
        expect(->
            throw new Exceptions.Error Exceptions.INVALID_ARGUMENT
        ).to.throwError((e) ->
            expect(e.name).to.be Exceptions.INVALID_ARGUMENT
            expect(e.type).to.be Exceptions.TYPE_ERROR
            expect(e.stack).to.not.be.ok()
        )