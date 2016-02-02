_ = require 'lodash'
fs = require 'fs-extra'
eco = require 'eco'
glob = require 'glob'
path = require 'path'
colors = require 'colors'
commander = require 'commander'
packageJSON = require './package.json'

class CommandWorker
  parseOptions: =>
    commander
      .usage '[options] <project-name>'
      .version packageJSON.version
      .option '--namespace <namespace>', 'Namespace, defaults to octoblu'
      .option '-d, --dir <dir>', 'Output directory for templates'
      .option '-p, --private', 'Private repo, use docker login'
      .option '--skip-sidekick', 'Skip the sidekick service templates'
      .option '--skip-service', 'Skip the service templates'
      .parse process.argv

    @namespace = commander.namespace ? 'octoblu'
    @dir = commander.dir
    @usePrivate = commander.private?
    @project_name = _.first commander.args
    @skipHealthcheck = commander.skipHealthcheck
    @skipRegister = commander.skipRegister
    @skipSidekick = commander.skipSidekick
    @skipService = commander.skipService

    unless @dir? && @project_name?
      commander.outputHelp()
      console.error colors.red '  <project-name> is required' unless @project_name?
      console.error colors.red '  -d, --dir argument is required\n' unless @dir?
      process.exit 1

  run: =>
    @parseOptions()

    console.log "making directory", colors.yellow @dir
    fs.mkdirpSync @dir

    templateNames = ['some-dummy-filename']
    templateNames.push '-sidekick@.service' unless @skipSidekick == true
    templateNames.push '@.service' unless @skipService == true

    glob path.join(__dirname, "templates-worker/**/{#{templateNames.join(',')}}.eco"), (error, files) =>
      return @die error if error?
      _.each files, (file) =>
        outputFilename = path.basename file.replace('.eco', '')
        template = fs.readFileSync file, "utf-8"
        filename = "#{@namespace}-#{@project_name}#{outputFilename}"

        console.log "Writing file", filename
        contents = eco.render template,
          project_name: @project_name
          namespace: @namespace
          usePrivate: @usePrivate

        fs.writeFileSync path.join(@dir, filename), contents

      @printEtcdInstructions()


  printEtcdInstructions: =>
    console.log ""
    console.log colors.bgWhite colors.black "ETCD INSTRUCTIONS"
    console.log ""
    console.log "etcdctl set /#{@namespace}/#{@project_name}/count 2"
    console.log ""
    console.log colors.bgRed colors.white "DON'T FORGET: SUBMIT YOUR SERVICE FILES TO FLEET"
    console.log ""
    console.log "fleetctl submit #{@dir}/*.service"
    console.log ""

  die: (error) =>
    if 'Error' == typeof error
      console.error colors.red error.message
    else
      console.error colors.red arguments...
    process.exit 1

new CommandWorker().run()