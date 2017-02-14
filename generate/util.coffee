fs = require 'fs'
yaml = require 'js-yaml'

module.exports =
  loadYaml: (fn)->yaml.safeLoad fs.readFileSync("#{__dirname}/../#{fn}", 'utf8')
