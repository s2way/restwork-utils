os = require 'os'
moment = require 'moment'

class SystemInfoSimple

    # Refresh the whole information about the server, it always refresh everything because of virtualization that could
    # change the cpus/route/memory/etc.
    # @method refresh
    # @return {json}
    refresh: ->
        data =
            created: moment().format()
            osHostName: os.hostname()
            osPlatform: os.platform()
            osRelease: os.release()
            osType: os.type()
            osArch: os.arch()
            nodePid: process.pid
        nodeMemUsgMb = process.memoryUsage()
        data.cpus = os.cpus().length
        data.memTotMb = parseFloat((os.totalmem() / 1024 / 1024).toFixed 2)
        data.memFreeMb = parseFloat((os.freemem() / 1024 / 1024).toFixed 2)
        data.memUsedMb = parseFloat((data.memTotMb - data.memFreeMb).toFixed 2)
        data.memFreePerc = parseFloat((data.memFreeMb / data.memTotMb * 100).toFixed 2)
        data.osDaysUP = parseFloat((os.uptime() / 3600 / 24).toFixed 2)
        loadAVG = os.loadavg()
        data.loadAVG1min = loadAVG[0]
        data.nodeDaysUp = parseFloat((process.uptime() / 3600 / 24).toFixed 2)
        data.heapTotMb = parseFloat((nodeMemUsgMb.heapTotal / 1024 / 1024).toFixed 2)
        data.heapUsedMb = parseFloat((nodeMemUsgMb.heapUsed / 1024 / 1024).toFixed 2)
        data.memRssMb = parseFloat((nodeMemUsgMb.rss / 1024 / 1024).toFixed 2)
        data.heapFreeMb = parseFloat((data.heapTotMb - data.heapUsedMb).toFixed 2)
        data.heapFreePerc = parseFloat((data.heapFreeMb / data.heapTotMb * 100).toFixed 2)
        data

module.exports = SystemInfoSimple