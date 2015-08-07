Command = require './../src/Command'
expect = require 'expect.js'

describe 'Command', ->

    it 'should return the stdout/error', (done) ->
        Command.exec 'ls', (err, stdout, stderr) ->
            expect(stdout).to.be.ok()
            done()