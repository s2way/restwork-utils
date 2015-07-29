###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###

Navigator = require './../src/Navigator'
expect = require 'expect.js'

describe 'Navigator', ->

    describe 'get', ->

        it 'should return undefined if the property does not exist', ->
            expect(Navigator.get {}, 'a.b.c.d').to.be undefined

        it 'should return null if the parent property is null', ->
            expect(Navigator.get
                a : null,
                'a.b'
            ).to.be null

        it 'should return the value', ->
            expectedValue = 10
            expect(Navigator.get
                a:
                    b: expectedValue,
                'a.b'
            ).to.be expectedValue
            expectedValue = 'string'
            expect(Navigator.get
                a:
                    b:
                        c:
                            d:
                                e:
                                    f: expectedValue
                'a.b.c.d.e.f'
            ).to.be expectedValue
