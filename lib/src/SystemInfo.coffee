os = require 'os'
ns = require 'nsutil'
moment = require 'moment'

class SystemInfo

    constructor: (@appName, @pid) ->

    gather: ->
        start = moment().format('x')
        loadAvg = os.loadavg()
        memory = ns.virtualMemory()
        swap = ns.swapMemory()
        disk = ns.diskUsage '/'
        proc = ns.Process @pid
        nodeMem = proc.memoryInfo()
        data =
            created: moment().utc().format()
            # os
            application: @appName
            osHostName: os.hostname()
            osPlatform: os.platform()
            osRelease: os.release()
            osType: os.type()
            osArch: os.arch()
            osDaysUP: parseFloat((os.uptime() / 3600 / 24).toFixed 2)
            osCpus: os.cpus().length
            osLoadAVG1Min: loadAvg[1]
            osLoadAVG5Min: loadAvg[2]
            # process
            nodePid: process.pid
            nodeDaysUp: parseFloat((process.uptime() / 3600 / 24).toFixed 2)
            nodeIO: proc.ioCounters()
            nodeFds: proc.numFds()
            nodeConnections: proc.connections()
            nodeOpenFiles: proc.openFiles()
            nodeMemVmsMb: parseFloat((nodeMem.vms / 1024 / 1024).toFixed 2)
            nodeMemRssMb: parseFloat((nodeMem.rss / 1024 / 1024).toFixed 2)
            nodeMemFreeMb: parseFloat(((nodeMem.vms - nodeMem.rss) / 1024 / 1024).toFixed 2)
            # os memory
            memTotMb: parseFloat((memory.total / 1024 / 1024).toFixed 2)
            memFreeMb: parseFloat((memory.free / 1024 / 1024).toFixed 2)
            memAvailMb: parseFloat((memory.avail / 1024 / 1024).toFixed 2)
            memUsedMb: parseFloat((memory.used / 1024 / 1024).toFixed 2)
            memBuffersMb: parseFloat((memory.buffers / 1024 / 1024).toFixed 2)
            memCachedMb: parseFloat((memory.cached / 1024 / 1024).toFixed 2)
            swapTotalMb: parseFloat((swap.total / 1024 / 1024).toFixed 2)
            swapUsedMb: parseFloat((swap.used / 1024 / 1024).toFixed 2)
            swapFreeMb: parseFloat((swap.free / 1024 / 1024).toFixed 2)
            # os disk
            diskTotalMb: parseFloat((disk.total / 1024 / 1024).toFixed 2)
            diskUsedMb: parseFloat((disk.used / 1024 / 1024).toFixed 2)
            diskFreeMb: parseFloat((disk.free / 1024 / 1024).toFixed 2) 

module.exports = SystemInfo