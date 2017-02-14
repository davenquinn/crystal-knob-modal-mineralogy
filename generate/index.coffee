global.d3 = require 'd3'
require '../d3-ternary/src/ternary'
createFields = require './fields'
createArrows = require './arrows'
plotData = require './data'
{exec} = require 'child_process'
Promise = require 'bluebird'
run Promise.promisify exec

# Get data from Python script
pipeline = (el, callback)->
  run("./modal-mineralogy.py", cwd: "#{__dirname}/..")
  .then JSON.parse
  .tap console.log data

graticule = d3.ternary.graticule()
  .majorInterval 0.1
  .minorInterval 0.05

scalebar = d3.ternary.scalebars()
  .labels ["Olivine","",""]
scalebar.axes[0].tickValues (i/10 for i in [5..9])
scalebar.axes[1].tickValues []
scalebar.axes[2].tickValues []

ternary = d3.ternary.plot()
  .clip(true)
  .call scalebar
  .call d3.ternary.vertexLabels(["Ol",'Opx','Cpx'])
  .call d3.ternary.neatline()
  .call graticule

ternary.scales[0].domain [0.4,1]
ternary.scales[1].domain [0,0.6]
ternary.scales[2].domain [0.6,0]

joinData = (el)->
  selection = el
    .selectAll ".dot"
      .data data.features

sz =
  width: 500
  height: 500

createPlot = (el, callback)->

  svg = d3.select el
    .attr sz
    .call ternary
  ternary.fit sz.width,sz.height

  svg.selectAll 'path'
    .attr fill: 'none'

  svg.select '.neatline'
    .attr
      fill: 'none'
      stroke: 'black'

  svg.selectAll '.graticule path'
    .attr
      stroke: '#cccccc'
      'stroke-width': ->
        maj = d3.select @
          .classed 'major'
        if maj then 0.5 else 0.25

  createArrows ternary
  createFields ternary
  plotData ternary, data

  # Modify vertex labels to tilt differently
  svg.selectAll '.vertex-label'
    .filter (d,i)-> i != 0
    .each (d,i)->
      r = if i == 1 then 30 else -30
      el = d3.select(@)
      t = el.attr 'transform'
      el.attr
        transform: t+"rotate(#{r})"
        dx: if i == 1 then -8 else 8
        dy: 15

  callback()

module.exports = pipeline
