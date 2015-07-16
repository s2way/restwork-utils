module.exports = (grunt) ->

    config =
        pkg: grunt.file.readJSON 'package.json'
        coffee:
            compile:
                expand: true
                flatten: false
                cwd: 'lib'
                src: ['**/*.coffee']
                dest: 'dist'
                ext: '.js'
        coffeelint:
            app: ['lib/**/*.coffee', 'Gruntfile.coffee']
            options:
                configFile: 'coffeelint.json'
        mochaTest:
            progress:
                options:
                    reporter: 'progress'
                    require: ['coffee-script/register', 'blanket']
                    captureFile: 'mochaTest.log'
                    quiet: false,
                    clearRequireCache: false
                src: ['lib/test/**/*.coffee']
            spec:
                options:
                    reporter: 'spec'
                    require: ['coffee-script/register', 'blanket']
                    captureFile: 'mochaTest.log'
                    quiet: false,
                    clearRequireCache: false
                src: ['lib/test/**/*.coffee']
            coverage:
                options:
                    reporter: 'html-cov'
                    quiet: true
                    captureFile: 'coverage.html'
                src: ['dist/test/**/*.js']
        watch:
            src:
                files: ['lib/**/**/*.coffee']
                tasks: ['lint', 'compile', 'test']
            gruntfile:
                files: ['Gruntfile.coffee']

    grunt.initConfig config

    require('load-grunt-tasks')(grunt)

    grunt.registerTask 'default', 'Watch', ->
        grunt.task.run 'watch'
    grunt.registerTask 'lint', ['coffeelint']
    grunt.registerTask 'compile', ['coffee:compile']
    grunt.registerTask 'test', ['mochaTest:progress']
