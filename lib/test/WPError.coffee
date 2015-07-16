WPError = require './../src/WPError'
expect = require 'expect.js'

describe 'WPError', ->

    it 'should throw error', ->
        expect(->
            new WPError.Fatal WPError.INVALID_ARGUMENT
        ).to.throwError((e) ->
            console.log e
        )