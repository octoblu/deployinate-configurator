commander = require 'commander'
packageJSON = require './package.json'

class Command
  constructor: ->

  parseOptions: =>
    commander
      .version packageJSON.version
      .command 'http', 'generate files for an http service'
      .parse process.argv

  run: =>
    @parseOptions()

command = new Command()
command.run()
