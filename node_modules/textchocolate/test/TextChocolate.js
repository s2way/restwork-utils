/*jslint devel: true, node: true, indent: 4 */
/*globals describe, it, beforeEach */

'use strict';

var TextChocolate = require('./../src/TextChocolate');
var expect = require('expect.js');
var path = require('path');

describe('TextChocolate.js', function () {
    var $this = this;

    describe('lang', function () {
        it('should change the current i18n', function () {
            $this.tc.lang('pt-BR');
            expect($this.tc.i18n).to.be.equal('pt-BR');
        });
    });

    function tests() {
        describe('translate', function () {
            it('should return a blank string if there is no msg', function () {
                expect($this.tc.translate()).to.be.equal('');
            });
            it('should return the key if the key string was not found', function () {
                expect($this.tc.translate('Oi')).to.be.equal('Oi');
            });
            it('should return the key if the i18n was not found', function () {
                $this.tc.lang('ru-RU');
                expect($this.tc.translate('hello_world')).to.be.equal('hello_world');
            });
            it('should return the singular translation', function () {
                $this.tc.lang('pt-BR');
                expect($this.tc.translate('hello_world')).to.be.equal('Oi mundo!');
            });
            it('should return the plural translation', function () {
                $this.tc.lang('pt-BR');
                expect($this.tc.translate('beer_please', 'p')).to.be.equal('%d cervejas, por favor.');
            });
        });

        describe('TextChocolate', function () {
            it('should throw an error if the translate file does not exist', function () {
                expect(function () {
                    var x = new TextChocolate('it/must/not/exist');
                    // smart jslint
                    x = x.toString();
                }).to.throwException(function (e) {
                    expect(e).to.be.a(Error);
                });
            });
            it('should throw an error if the translate file is not a file', function () {
                expect(function () {
                    // We hope you are a unix user ;)
                    var x = new TextChocolate('/tmp');
                    // smart jslint
                    x = x.toString();
                }).to.throwException(function (e) {
                    expect(e).to.be.a(Error);
                });
            });
        });
    }

    describe('Building passing a file', function () {
        $this.tc = new TextChocolate(path.resolve('./sampleTranslateFile.json'));
        tests();
    });

    describe('Building passing a json', function () {
        var data = {
            "hello_world" : {
                "en-US " : {
                    "s" : "Hello world!",
                    "p" : "Hello worlds!"
                },
                "pt-BR" : {
                    "s" : "Oi mundo!",
                    "p" : "Oi mundos"
                },
                "de-DE" : {
                    "s" : "Hallo Welt!"
                }
            },
            "beer_please" : {
                "en-US " : {
                    "s": "%d beer, please.",
                    "p": "%d beers, please."
                },
                "pt-BR" : {
                    "s" : "%d cerveja, por favor.",
                    "p" : "%d cervejas, por favor."
                },
                "de-DE" : {
                    "s" : "Bitte, %d Bier.",
                    "p" : "Bitte, %d Biere."
                }
            }
        };
        $this.tc = new TextChocolate(data);
        tests();
    });
});
