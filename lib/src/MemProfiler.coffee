# memWatch = require 'memwatch'
# heapDump = require 'heapdump'

# class MemProfiler

#     constructor: ->
#         memWatch.on 'leak', (info) =>
#             console.log 'LEAK', info
#             file = "./leak-#{process.pid}-#{Date.now()}-.heapsnapshot"
#             heapDump.writeSnapshot file, (err) ->
#                 console.log err if err?
#                 console.log 'Heap snapshot taken'

#         memWatch.on 'stats', (stats) =>
#             console.log 'STATS', stats
#             @diff()
#             @monitor()
#         @monitor()

#     monitor: ->
#         @snapShot = new memWatch.HeapDiff()

#     diff: ->
#         diff = @snapShot.end()

# module.exports = MemProfiler