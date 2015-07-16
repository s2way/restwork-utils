class WPError

    @TYPE_FATAL: 'Fatal'
    @TYPE_ERROR: 'Error'
    @INVALID_ARGUMENT: 'Invalid argument'

    @Fatal: (@name, @message = '') ->
        @type = WPError.TYPE_FATAL
        @stack = new Error().stack

    @Error: (@name, @message = '') ->
        @type = WPError.TYPE_FATAL

module.exports = WPError