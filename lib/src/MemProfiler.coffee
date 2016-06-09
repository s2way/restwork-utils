
class MemProfiler

    constructor: ->
        memWatch = null
        heapDump = null
        try
            require.resolve 'memwatch'
            require.resolve 'heapdump'
            memWatch = require 'memwatch'
            heapDump = require 'heapdump'
        catch e
            console.log 'Heads up! The monitoring was activated but there are modules missing'
            console.log e
            return

        memWatch.on 'leak', (info) =>
            console.log 'LEAK', info
            file = "./leak-#{process.pid}-#{Date.now()}-.heapsnapshot"
            heapDump.writeSnapshot file, (err) ->
                console.log err if err?
                console.log 'Heap snapshot taken'

        memWatch.on 'stats', (stats) =>
            console.log 'STATS', stats

    monitor: ->
        @snapShot = new memWatch.HeapDiff()

    diff: ->
        diff = @snapShot.end()

module.exports = MemProfiler