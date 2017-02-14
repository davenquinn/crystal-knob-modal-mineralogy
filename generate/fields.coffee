util = require './util'

fields = util.loadYaml "peridotite-fields.yaml"

module.exports = (ternary)->
  sel = ternary.plot()
    .selectAll 'path.field'
    .data fields

  g = sel.enter()
    .append 'path'
    .attr
      class: 'field'
      d: (d)->ternary.path(d.vertices)
      stroke: '#aaaaaa'
      fill: 'transparent'
      'stroke-width': 1.5
      'stroke-linejoin': 'miter'

  cMean = (i)->
    (d)->d3.mean d.map (a)->a[i]

  sel = ternary.node()
    .selectAll 'text.field-label'
    .data fields

  sel.enter()
    .append 'text'
    .attr
      class: 'field-label'
      fill: '#888888'
      'text-anchor': 'middle'
      'dominant-baseline': 'middle'
    .text (d)->d.name
    .each (d)->
      vx = (cMean(i)(d.vertices) for i in [0...3])
      c = ternary.point(vx)
      l = d.label or {}
      t = "translate(#{c[0]},#{c[1]})"
      r = l.rotate or 0
      if r
        t += "rotate(#{r})"

      d3.select @
        .attr
          transform: t
          dx: l.dx or 0
          dy: l.dy or 0

