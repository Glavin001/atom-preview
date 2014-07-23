'use strict'

module.exports = ->

  # Initialize configuration
  @initConfig

    # CoffeeLint configuration
    coffeelint:
      grunt:
        src: ['Gruntfile.coffee']
      lib:
        src: ['lib/**/*.coffee']
      spec:
        src: ['spec/**/*.coffee']


    lesslint:
      src: ['stylesheets/**/*.less']

    watch:
      options:
        interrupt: true
      grunt:
        files: ['Gruntfile.coffee']
        tasks: ['coffeelint:grunt']
      lib:
        files: ['lib/**/*.coffee']
        tasks: ['coffeelint:lib']
      spec:
        files: ['spec/**/*.coffee']
        tasks: ['coffeelint:spec']
      stylesheets:
        files: ['stylesheets/**/*.less']
        tasks: ['lesslint']

  # Load tasks
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-lesslint'
  @loadNpmTasks 'grunt-apm'
  @loadNpmTasks 'grunt-contrib-watch'

  # Aggregate some tasks
  @registerTask 'lint', ['lesslint', 'coffeelint']
  @registerTask 'link', ['apm-link']
  @registerTask 'unlink', ['apm-unlink']
  @registerTask 'test', ['apm-test']
  @registerTask 'dev', ['apm-link', 'watch']
  @registerTask 'default', ['lint', 'test']
