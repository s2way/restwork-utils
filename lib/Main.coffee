class Main

module.exports = Main

module.exports.Exceptions = require './src/Exceptions'
module.exports.Files = require './src/Files'
module.exports.Navigator = require './src/Navigator'
module.exports.Validator = require './src/Validator'
module.exports.Translator = require './src/Translator'
module.exports.Rules = require './src/Rules'
module.exports.SystemInfo = require './src/SystemInfo'
module.exports.XML = require './src/XML'
module.exports.QueryBuilder = require './src/QueryBuilder'
module.exports.Watcher = require './src/Watcher'
module.exports.Connectors = {}
module.exports.Connectors.Fs = require './src/connectors/Fs'
module.exports.Connectors.Http = require './src/connectors/Http'
module.exports.Connectors.MySQL = require './src/connectors/MySQL'

module.exports.Connectors.CouchMuffin = require './src/connectors/CouchMuffin'
module.exports.Connectors.Couchbase = require './src/connectors/Couchbase'