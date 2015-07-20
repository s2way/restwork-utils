class Exceptions

    # Defaults
    @TYPE_FATAL: 'Fatal'
    @TYPE_ERROR: 'Error'

    # Errors
    @INVALID_ARGUMENT: 'Invalid argument'
    @NO_SRC_FILE: 'Source is missing or it is not a file'
    @DST_EXISTS: 'Destination already exists.'
    @NOT_JSON: 'File content is not a valid JSON'

    @Fatal: (@name, @message = '') ->
        @type = Exceptions.TYPE_FATAL
        @stack = new Error().stack

    @Error: (@name, @message = '') ->
        @type = Exceptions.TYPE_ERROR

module.exports = Exceptions