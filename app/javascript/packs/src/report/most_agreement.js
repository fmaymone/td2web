class MostAgreement {

  constructor(locale, id, data) {
		this.chart_height = 300
		this.chart_width = 400
		this.hpad = 50
		this.vpad = 30
		this.locale = locale
		this.container_id = id
		this.container = document.getElementById(this.container_id)
		this.definition = data
		this.data = this.definition["data"]
		this.height = this.chart_height + this.vpad * 2
		this.width = this.chart_width + this.hpad * 2
    this.question_colors = ['#627E54', '#3F81B9', '#BB2F29', '#AA7A3C', '#585687']
  }

  render() {
    console.log('- Init MostAgreement...')
    this.set_title()
    this.render_chart()
    console.log('- Init MostAgreement [OK]')
  }

  set_title() {
    const title = this.container.querySelector('header h1.chart_title')
    title.textContent = this.definition["title"][this.locale]
  }

  render_chart() {
    console.log('--- Start rendering of chart...')

    const chart_container = this.container.querySelector('.chart_container')
    const questions = this.definition.labels["_index"]
    const participant_count = this.data[0]["values"].length

    const chart_drawing_container = document.createElement("div")
    chart_drawing_container.setAttribute("class", "agreement_chart_drawing_container")
    chart_container.appendChild(chart_drawing_container)

    // Init SVG container
    var svg = d3.select(chart_drawing_container)
      .append("svg")
      .attr("class", "most_agreement_chart")
      .attr("width", this.width)
      .attr("height", this.height)

    var question_color = d3.scaleOrdinal()
      .domain(questions)
      .range(this.question_colors)

    var x_scale = d3.scaleLinear()
      .domain([0, participant_count - 1])
      .range([this.chart_height, 0])

    var y_scale = d3.scaleLinear()
      .domain([9,1])
      .range([0, this.chart_height])

      var y_gridlines = d3.axisLeft()
        .scale(y_scale)
        .tickSize(-this.chart_width)
      
    var y_axis = svg.append("g")
      .call(y_gridlines)
      .attr("transform",`translate(${this.hpad},${this.vpad})`)

    var line = d3.line()
      .x((d) => x_scale(+d[0]))
      .y((d) => y_scale(+d[1]))
    var lines = svg.selectAll("agreement_lines")
      .data(this.data)
      .enter()
      .append("path")
        .attr("d", (d) => line(d.values))
        .attr("stroke", (d) => question_color(d.label))
        .style("stroke-width",4)
        .style("fill", "none")
        .attr("transform",`translate(${this.hpad},${this.vpad})`)
    var dots = svg.selectAll("agreement_points")
      .data(this.data)
      .enter()
        .append("g")
        .style("fill", (d) => question_color(d.label))
      .selectAll("points")
      .data((d) => d.values)
      .enter()
        .append("circle")
        .attr("cx", (d) => x_scale(+d[0]))
        .attr("cy", (d) => y_scale(+d[1]))
        .attr("r", 5)
        .attr("stroke", "white")
        .attr("transform",`translate(${this.hpad},${this.vpad})`)

    const legend_container = document.createElement("div")
    legend_container.setAttribute("id", "most_agreement_legend")
    legend_container.setAttribute("class", "agreement_legend")

    this.data.forEach((d, i) => {
      let item = document.createElement('p')
      let icon = document.createElement('span')
      icon.setAttribute("class", 'agreement_legend_item_number')
      icon.style.background = question_color(d.label)
      let icon_text = document.createTextNode(i+1)
      icon.appendChild(icon_text)
      item.appendChild(icon)
      let text = document.createTextNode(" " + this.definition.labels[d.label][this.locale])
      item.appendChild(text)
      legend_container.appendChild(item)
    })

    chart_container.appendChild(legend_container)

    console.log('--- Start rendering of chart...')
  }
}

export default MostAgreement
