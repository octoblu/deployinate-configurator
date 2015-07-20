_ = require 'lodash'
fs = require 'fs-extra'
eco = require 'eco'
glob = require 'glob'
path = require 'path'
colors = require 'colors'
commander = require 'commander'

class DeployinateConfigurator
  parseOptions: =>
    commander
      .usage '[options] <project name>'
      .option '--namespace <namespace>', 'Namespace, defaults to octoblu'
      .option '-d, --dir <dir>', 'Output directory for templates, defaults to .systemd'
      .parse process.argv

    @namespace = commander.namespace ? 'octoblu'
    @dir = commander.dir ? '.systemd'
    @project_name = _.first commander.args

  run: =>
    @parseOptions()

    return @die new Error('No name specified') unless @project_name?

    console.log "making directory", colors.yellow @dir
    fs.mkdirpSync @dir

    glob path.join(__dirname, 'templates/**/*.eco'), (error, files) =>
      return @die error if error?
      _.each files, (file) =>
        outputFilename = path.basename file.replace('.eco', '')
        template = fs.readFileSync file, "utf-8"
        _.each ['blue', 'green'], (color) =>
          filename = "#{@namespace}-#{@project_name}-#{color}#{outputFilename}"
          console.log "Writing file", colors[color] filename
          contents = eco.render template,
            project_name: @project_name
            namespace: @namespace
            color: color

          fs.writeFileSync path.join(@dir, filename), contents

      @printEtcdInstructions()


  printEtcdInstructions: =>
    console.log ""
    console.log colors.bgWhite colors.black "ETCD INSTRUCTIONS"
    console.log ""
    console.log "etcdctl set /#{@namespace}/#{@project_name}/count 2"
    console.log "etcdctl set /#{@namespace}/#{@project_name}/host <domain name>"
    console.log "etcdctl set /#{@namespace}/#{@project_name}/blue/port <port>"
    console.log "etcdctl set /#{@namespace}/#{@project_name}/green/port <port>"
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

new DeployinateConfigurator().run()
