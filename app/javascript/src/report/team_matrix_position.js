import * as d3 from 'd3'

class TeamMatrixPosition {
  constructor(locale, id, data) {
    this.chart_height = 400
    this.hpad = 175
    this.vpad = 75 
    this.label_size = 16
    this.tick_label_size = 12
    this.locale = locale
    this.container_id = id
    this.container = document.getElementById(this.container_id)
    this.definition = data
    this.data = this.definition["data"]
    this.height = this.chart_height + this.vpad * 2
    this.width = this.chart_height + this.hpad * 2
  }

  render() {
    console.log('- Init TeamMatrixPosition...')
    this.set_title()
    this.render_chart()
    console.log('- Init TeamMatrixPosition [OK]')
  }

  set_title() {
    const title = this.container.querySelector('div.chart_title')
    title.textContent = this.definition["title"][this.locale]
  }

  debug_info() {
    console.log('Locale: ', this.locale)
    console.log(this.definition)
    console.log(this.data)
  }

  value(val) {
    let v = Number(val)
    if (isNaN(v)) {
      return(0.0)
    } else {
      return(v)
    }
  }

  render_chart() {
    console.log('--- Start rendering of chart...')

    const chart_container = this.container.querySelector('.chart_container')

    // Init SVG container
    var svg = d3.select(chart_container)
      .append("svg")
      .attr("class", "team_matrix_position_chart")
      .attr("width", this.width)
      .attr("height", this.height)

    // Chart Background
    var background = svg.append("g")
        .attr("class", "team_matrix_position_chart_background")
    /// Top-Left Quad
    background.append("rect")
      .attr("x", this.hpad)
      .attr("y", this.vpad)
      .attr("width", this.chart_height / 2)
      .attr("height", this.chart_height / 2)
      .attr("fill", "#537655")
    /// Top-Right Quad
    background.append("rect")
      .attr("x", this.hpad + this.chart_height / 2)
      .attr("y", this.vpad)
      .attr("width", this.chart_height / 2)
      .attr("height", this.chart_height / 2)
      .attr("fill", "#1D77AB")
    /// Bottom-Left Quad
    background.append("rect")
      .attr("x", this.hpad)
      .attr("y", this.vpad + this.chart_height / 2)
      .attr("width", this.chart_height / 2)
      .attr("height", this.chart_height / 2)
      .attr("fill", "#926F47")
    /// Bottom-Right Quad
    background.append("rect")
      .attr("x", this.hpad + this.chart_height / 2)
      .attr("y", this.vpad + this.chart_height / 2)
      .attr("width", this.chart_height / 2)
      .attr("height", this.chart_height / 2)
      .attr("fill", "#992432")

    // Horizontal Axis
    var x_scale = d3.scaleLinear()
      .domain([1,9])
      .range([this.hpad, this.chart_height + this.hpad])
    var x_axis = svg
      .append("g")
        .attr("class", "team_matrix_position_chart_xaxis")
        .attr("transform",`translate(0,${this.height / 2})`)
      .call(d3.axisBottom(x_scale))
      .call(g => g.select(".tick:nth-of-type(5)").remove())

    // Vertical Axis
    var y_scale = d3.scaleLinear()
      .domain([1,9])
      .range([this.vpad, this.chart_height + this.vpad])
    var y_axis = svg
      .append("g")
      .attr("class", "team_matrix_position_chart_yaxis")
      .attr("transform",`translate(${this.width / 2},0)`)
      .call(d3.axisLeft(y_scale))
      .call(g => g.select(".tick:nth-of-type(5)").remove())

    // Axis Labels
    var labels = svg.append("g")
      .attr("class","team_matrix_position_chart_labels")
    labels.append("text")
      .attr("x", 0)
      .attr("y", this.height / 2 )
      .attr("text-anchor", "start")
      .attr("alignment-baseline", "bottom")
      .text(this.definition["labels"]["Low Productivity"][this.locale])
    labels.append("text")
      .attr("x", this.width)
      .attr("y", this.height / 2)
      .attr("text-anchor", "end")
      .attr("alignment-baseline", "middle")
      .text(this.definition["labels"]["High Productivity"][this.locale])
    labels.append("text")
      .attr("x", this.width / 2)
      .attr("y", this.vpad / 2 )
      .attr("alignment-baseline", "bottom")
      .attr("text-anchor", "middle")
      .text(this.definition["labels"]["Low Positivity"][this.locale])
    labels.append("text")
      .attr("x", this.width / 2)
      .attr("y", this.height - this.vpad / 2)
      .attr("alignment-baseline", "top")
      .attr("text-anchor", "middle")
      .text(this.definition["labels"]["High Positivity"][this.locale])

    // Graph
    var graph = svg.append("g")
      .attr("class", "team_matrix_position_chart_graph")
    const line_color = 'white'
    /// Vertexes
    graph.append("circle")
      .attr("cx",x_scale(this.value( this.data["Low Positivity"] )))
      .attr("cy",y_scale(this.value( this.data["Low Productivity"] )))
      .attr("r", 3)
      .attr('stroke', line_color)
      .attr('fill', line_color)
    graph.append("circle")
      .attr("cx",x_scale(this.value( this.data["Low Productivity"] )))
      .attr("cy",y_scale(this.value( this.data["High Positivity"] )))
      .attr("r", 3)
      .attr('stroke', line_color)
      .attr('fill', line_color)
    graph.append("circle")
      .attr("cx",x_scale(this.value( this.data["High Productivity"] )))
      .attr("cy",y_scale(this.value( this.data["Low Positivity"] )))
      .attr("r", 3)
      .attr('stroke', line_color)
      .attr('fill', line_color)
    graph.append("circle")
      .attr("cx",x_scale(this.value( this.data["High Productivity"] )))
      .attr("cy",y_scale(this.value( this.data["High Positivity"] )))
      .attr("r", 3)
      .attr('stroke', line_color)
      .attr('fill', line_color)
    graph.append("rect")
      .style("opacity", 0.5)
      .attr("fill", line_color)
      .attr("x", x_scale(this.value( this.data["Low Productivity"] )))
      .attr("y", y_scale(this.value( this.data["Low Positivity"] )))
      .attr("width",(this.value( this.data["High Productivity"] ) - this.value( this.data["Low Productivity"] ) ) * ( this.chart_height / 8 ))
      .attr("height",(this.value( this.data["High Positivity"] ) - this.value( this.data["Low Positivity"] ) ) * ( this.chart_height / 8 ))
    graph.append('line')
      .style('stroke', line_color)
      .style('stroke-width', 2)
      .attr("x1",x_scale(this.value( this.data["Low Productivity"] )))
      .attr("y1",y_scale(this.value( this.data["Low Positivity"] )))
      .attr("x2",x_scale(this.value( this.data["Low Productivity"] )))
      .attr("y2",y_scale(this.value( this.data["High Positivity"] )))
    graph.append('line')
      .style('stroke', line_color)
      .style('stroke-width', 2)
      .attr("x1",x_scale(this.value( this.data["Low Productivity"] )))
      .attr("y1",y_scale(this.value( this.data["High Positivity"] )))
      .attr("x2",x_scale(this.value( this.data["High Productivity"] )))
      .attr("y2",y_scale(this.value( this.data["High Positivity"] )))
    graph.append('line')
      .style('stroke', line_color)
      .style('stroke-width', 2)
      .attr("x1",x_scale(this.value( this.data["High Productivity"] )))
      .attr("y1",y_scale(this.value( this.data["High Positivity"] )))
      .attr("x2",x_scale(this.value( this.data["High Productivity"] )))
      .attr("y2",y_scale(this.value( this.data["Low Positivity"] )))
    graph.append('line')
      .style('stroke', line_color)
      .style('stroke-width', 2)
      .attr("x1",x_scale(this.value( this.data["High Productivity"] )))
      .attr("y1",y_scale(this.value( this.data["Low Positivity"] )))
      .attr("x2",x_scale(this.value( this.data["Low Productivity"] )))
      .attr("y2",y_scale(this.value( this.data["Low Positivity"] )))

    console.log('--- Finished rendering of chart')
  }
}

export default TeamMatrixPosition
