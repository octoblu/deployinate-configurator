commander = require 'commander'
packageJSON = require './package.json'

class Command
  constructor: ->

  parseOptions: =>
    commander
      .version packageJSON.version
      .command 'service', 'generate files for a service service'
      .command 'worker', 'generate files for a worker service'
      .parse process.argv

  run: =>
    @parseOptions()

command = new Command()
command.run()
