###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###

expect = require 'expect.js'
SystemInfo = require './../src/SystemInfo'

describe 'SystemInfo', ->

    describe 'refresh', ->
        expect(SystemInfo.refresh).to.be.ok()
