commander = require 'commander'
packageJSON = require './package.json'

class Command
  constructor: ->

  parseOptions: =>
    commander
      .version packageJSON.version
      .command 'http', 'generate files for an http service'
      .command 'traefik', 'generate files for a traefik service'
      .command 'worker', 'generate files for a worker service'
      .parse process.argv

  run: =>
    @parseOptions()

command = new Command()
command.run()
