/*jslint devel: true, node: true, indent: 4, vars: true, maxlen: 256 */

'use strict';

var fs = require('fs');
/**
 * Function __apply inject the prototypes inside the context to work with _T()
 *
 * @param context
 * @param func
 * @returns {Function}
 * @private
 */
var __apply = function (context, func) {
    return function () {
        return func.apply(context, arguments);
    };
};
/**
 * TextcChocolate constructor
 *
 * @param {*} translationJson It can be a string with the file location or the data itfself
 * @param {string} i18n The RFC i18n standard such pt-BR ru-RU de-DE en-UK
 * @constructor
 */
function TextChocolate(translationJson, i18n) {
    this.defaultLang = 'en-US';
    this.lang(i18n);
    this.data = {};
    var $this = this;
    if (typeof translationJson === 'string') {
        if (!fs.existsSync(translationJson)) {
            throw new Error('FileNotFound');
        }
        var stats = fs.lstatSync(translationJson);
        if (!stats.isFile()) {
            throw new Error('InvalidFile');
        }
        (function transformJsonFile2HashFunctions() {
            $this.data = JSON.parse(fs.readFileSync(translationJson, 'utf8'));
        }());
    } else {
        $this.data = translationJson;
    }
    var i;
    for (i in TextChocolate.prototype) {
        if (TextChocolate.prototype.hasOwnProperty(i)) {
            this[i] = __apply(this, this[i]);
        }
    }
}
/**
 * Function lang it sets the translate language
 *
 * @param i18n The RFC i18n standard such pt-BR ru-RU de-DE en-UK
 */
TextChocolate.prototype.lang = function (i18n) {
    this.i18n = i18n || this.defaultLang;
};
/**
 * Function translate
 *
 * @param {string} key The key that points to your desired message
 * @param {string} n The type of desired translation for plurals the default is 's'
 * @returns {*} It will return the key if it was not found
 */
TextChocolate.prototype.translate = function (key, n) {
    if (!key) {
        return '';
    }
    var message = this.data[key];
    if (message !== undefined) {
        var language = message[this.i18n];
        if (language !== undefined) {
            var p = n || 's';
            var translation = language[p];
            if (translation !== undefined) {
                return translation;
            }
        }
    }
    return key;
};

module.exports = TextChocolate;