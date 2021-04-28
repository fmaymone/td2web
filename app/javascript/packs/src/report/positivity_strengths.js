class PositivityStrengths {
	constructor(locale, id, data) {
		this.chart_height = 400
		this.chart_width = 450 
		this.hpad = 300
		this.vpad = 30
		this.label_size = 16
		this.tick_label_size = 12
		this.locale = locale
		this.container_id = id
		this.container = document.getElementById(this.container_id)
		this.definition = data
		this.data = this.definition["data"]
		this.height = this.chart_height + this.vpad * 2
		this.width = this.chart_width + this.hpad * 2
	}

	render() {
		console.log('- Init PositivityStrengths...')
		this.set_title()
		this.render_chart()
		console.log('- Init PositivityStrengths [OK]')
	}

	set_title() {
		const title = this.container.querySelector('header h1.chart_title')
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
		.attr("class", "positivity_strengths_chart")
		.attr("width", this.width)
		.attr("height", this.height)

		var y_scale = d3.scaleBand()
			.range([0,this.chart_height])
			.domain(this.definition.labels._index)
			.padding(0.4)

		var y_axis = d3.axisLeft(y_scale)
			.tickSize(15)

		svg.append("g")
			.call(y_axis)
			.attr("font-size","16")
			.attr("class","y_axis")
			.attr("transform",`translate(${this.hpad},${this.vpad})`)

		var x_scale = d3.scaleLinear()
			.range([0,this.chart_width])
			.domain([1,9])

		var x_axis = d3.axisBottom(x_scale)
	
		svg.append("g")
			.call(x_axis)
			.attr("class","x_axis")
			.attr("font-size","12")
			.attr("transform",`translate(${this.hpad},${this.vpad+this.chart_height})`)

		var x_gridline = d3.axisBottom()
			.tickFormat("")
			.scale(x_scale)
			.tickSize(-this.chart_height)

		svg.append("g")
			.attr("transform", `translate(${this.hpad},${this.vpad+this.chart_height})`)
			.call(x_gridline)

		var bars = svg.append("g")
			.attr("class","bars")

		this.definition.labels._index.forEach((factor, factor_index) => {
			bars.append("rect")
				.attr("x", this.hpad)
				.attr("y", this.vpad + y_scale(factor))
				.attr("width", x_scale(9))
				.attr("height", y_scale.bandwidth())
				.attr("fill","#FFFCD5")
			bars.append("rect")
				.attr("x", this.hpad)
				.attr("y", this.vpad + y_scale(factor))
				.attr("width", x_scale(this.data[factor]))
				.attr("height", y_scale.bandwidth())
				.attr("fill","#2A649D")
			bars.append("text")
				.attr("alignment-baseline", "middle")
				.attr("x", this.hpad + 10)
				.attr("y", this.vpad + 18 + y_scale(factor))
				.attr("fill","white")
				.attr("font-size","16")
				.attr("font-family", "Helvetica")
				.text(this.data[factor])
		})
		

	}
}

export default PositivityStrengths
