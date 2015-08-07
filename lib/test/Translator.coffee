expect = require 'expect.js'
path = require 'path'
Translator = require './../src/Translator'

describe 'Translator', ->

    describe 'get', ->

        it 'should return an object with the original message if no config has found', ->
            instance = new Translator()
            expect(instance.get 'my_test', 1).to.be.equal 'my_test'

        it 'should set lang if its passed', ->

            langCalled = false

            instance = new Translator()
            instance.tc =
                translate: () ->
                lang: () ->
                    langCalled = true
            instance.get 'message', 0, 'newLang'
            expect(langCalled).to.be.ok()