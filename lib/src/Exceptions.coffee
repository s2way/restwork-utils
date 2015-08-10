###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###

class Exceptions

    # Defaults
    @TYPE_FATAL: 'Fatal'
    @TYPE_ERROR: 'Error'

    # Errors
    @NOT_JSON: 'File content is not a valid JSON'
    @DST_EXISTS: 'Destination already exists.'
    @NO_SRC_FILE: 'Source is missing or it is not a file'
    @INVALID_OBJECT: 'Invalid object'
    @INVALID_ARGUMENT: 'Invalid argument'
    @ILLEGAL_ARGUMENT: 'Illegal argument'
    @NOT_FOUND: 'Not found'
    @TIMEOUT: 'Timeout'

    @Fatal: (@name, @message = '') ->
        @type = Exceptions.TYPE_FATAL
        @stack = new Error().stack

    @Error: (@name, @message = '') ->
        @type = Exceptions.TYPE_ERROR

module.exports = Exceptions