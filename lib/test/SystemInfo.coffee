###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###

expect = require 'expect.js'
SystemInfo = require './../src/SystemInfo'

describe 'SystemInfo', ->

    describe 'gather', ->
        systemInfo = new SystemInfo
        expect(systemInfo.gather).to.be.ok()
