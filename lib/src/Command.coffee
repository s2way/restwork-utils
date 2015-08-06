sys = require 'sys'
exec = require('child_process').exec

class Command

    # Cb parameters err, stdout, stderr
    @exec: (command, cb) ->
        exec command, cb

module.exports = Command