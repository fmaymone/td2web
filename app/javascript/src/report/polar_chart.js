class PolarChart {
  constructor(locale, id, data) {
    this.chart_height = 475
    this.hpad = 200
    this.vpad = 30
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
    console.log('- Init PolarChart...')
    this.set_title()
    this.render_chart()
    console.log('- Init PolarChart [OK]')
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
    const radians = 2 * Math.PI
    const chart_container = this.container.querySelector('.chart_container')
    const radius = this.chart_height / 2
    const chart_center = { x: this.width / 2, y: this.height / 2 }
    const factors = this.definition["labels"]["_index"]
    const step_count = this.definition["domain"][1] - this.definition["domain"][0]
    const angle = radians / factors.length

    // Init SVG container
    var svg = d3.select(chart_container)
      .append("svg")
      .attr("class", "team_matrix_position_chart")
      .attr("width", this.width)
      .attr("height", this.height)

    // Draw Axis
    var axis = svg.append("g")
      .attr("class","polar_chart_axis")

    /// Generate Axis
    for(let step=0;step<step_count;step++) {
      let step_radius = (step + 1) * radius / step_count
      let tick_points = []

      factors.forEach((factor, factor_index) => {
        let outer_point = [
          step_radius * Math.cos(angle * factor_index) + chart_center.x,
          step_radius * Math.sin(angle * factor_index) + chart_center.y
        ]

        tick_points.push(outer_point)
        if (step == step_count - 1) {
          // Radial line to outer polygon
          axis.append("line")
            .attr("x1", chart_center.x)
            .attr("y1", chart_center.y)
            .attr("x2", outer_point[0])
            .attr("y2", outer_point[1])
            .attr("stroke", "#aaa")
            .attr("stroke-width", 1)
          // Factor labels
          let label = axis.append("text")
            .style("fill", "black")
            .style("font-family", "Helvetica")
            .style("font-size", "1em")
            .text(this.definition.labels[factor][this.locale])
          if (outer_point[0] > chart_center.x) {
            label
              .attr("text-anchor", "start")
              .attr("x", outer_point[0] + 10)
          } else {
            label
              .attr("text-anchor", "end")
              .attr("x", outer_point[0] - 10)
          }
          if (outer_point[1] > chart_center.y + 15) {
            label
              .attr("alignment-baseline", "bottom")
              .attr("y", outer_point[1] + 10)
          } else {
            label
              .attr("alignment-baseline", "bottom")
              .attr("y", outer_point[1])
          }
        }
      })

      // Tick Polygon
      axis.append("polygon")
        .attr("fill", "none")
        .attr("stroke", "#aaa")
        .attr("stroke-width", 2)
        .attr("points", tick_points)

      axis.append("text")
        .attr("x", chart_center.x)
        .attr("y", tick_points[11][1] - 2)
        .attr("text-anchor","middle")
        .style("fill", "red")
        .style("font-family", "Helvetica")
        .style("font-size", "1em")
        .style("font-weight", "bold")
        .text(step + 2)
    }

    // Center tick label
    axis.append("text")
      .attr("x", chart_center.x)
      .attr("y", chart_center.y - 2)
      .attr("text-anchor","middle")
      .style("fill", "red")
      .style("font-family", "Helvetica")
      .style("font-size", "1em")
      .style("font-weight", "bold")
      .text(1)

    let graph_points = []
    factors.forEach((factor, factor_index) => {
      let point_radius = this.value(this.data[factor] - 1) * radius / step_count
      let point = [
        point_radius * Math.cos(angle * factor_index) + chart_center.x,
        point_radius * Math.sin(angle * factor_index) + chart_center.y
      ]
      graph_points.push(point)
    })

    axis.append("polygon")
      .attr("fill", "#333366")
      .attr("fill-opacity", 0.4)
      .attr("stroke", "#333366")
      .attr("stroke-width", 2)
      .attr("points", graph_points)

    console.log('--- Finished rendering of chart')
  }
}

export default PolarChart
