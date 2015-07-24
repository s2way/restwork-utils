os = require 'os'

class SystemInfo

    # Refresh the whole information about the server, it always refresh everything because of virtualization that could
    # change the cpus/route/memory/etc.
    # @method refresh
    # @return {json}
    @refresh: ->
        data =
            osHostName: os.hostname()
            osPlatform: os.platform()
            osRelease: os.release()
            osType: os.type()
            osArch: os.arch()
            nodeFeatures: process.features
            nodeLibsVer: process.versions
            nodeArgs: process.execArgv
            nodeConfig: process.config
            nodeUid: process.getuid()
            nodeGid: process.getgid()
            nodeEnv: process.env
            nodePid: process.pid
            nodeModuleLoadList: process.moduleLoadList
        nodeMemUsgMb = process.memoryUsage()
        data.cpus = os.cpus().length
        data.memTotMb = parseFloat((os.totalmem() / 1024 / 1024).toFixed 2)
        data.memFreeMb = parseFloat((os.freemem() / 1024 / 1024).toFixed 2)
        data.memUsedMb = parseFloat((data.memTotMb - data.memFreeMb).toFixed 2)
        data.memFreePerc = parseFloat((data.memFreeMb / data.memTotMb * 100).toFixed 2)
        data.osDaysUP = parseFloat((os.uptime() / 3600 / 24).toFixed 2)
        data.loadAVG = os.loadavg()
        data.nodeDaysUp = parseFloat((process.uptime() / 3600 / 24).toFixed 2)
        data.heapTotMb = parseFloat((nodeMemUsgMb.heapTotal / 1024 / 1024).toFixed 2)
        data.heapUsedMb = parseFloat((nodeMemUsgMb.heapUsed / 1024 / 1024).toFixed 2)
        data.memRssMb = parseFloat((nodeMemUsgMb.rss / 1024 / 1024).toFixed 2)
        data.heapFreeMb = parseFloat((data.heapTotMb - data.heapUsedMb).toFixed 2)
        data.heapFreePerc = parseFloat((data.heapFreeMb / data.heapTotMb * 100).toFixed 2)
        JSON.stringify data

module.exports = SystemInfo
