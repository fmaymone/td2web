class HighestLowestProductivityRatings {
  constructor(locale, id, data) {
    this.chart_width = 800
    this.locale = locale
    this.container_id = id
    this.container = document.getElementById(this.container_id)
    this.definition = data
    this.data = this.definition["data"]
    this.height = this.chart_height + this.vpad * 2
    this.width = this.chart_width + this.hpad * 2
  }

  render() {
    console.log('- Init HighestLowestProductivityRatings...')
    this.set_title()
    this.render_chart()
    console.log('- Init HighLowestProductivityRatings [OK]')
  }

  set_title() {
    if (this.container === undefined) return(false)

    var title
    try {
      title = this.container.querySelector('div.chart_title')
    } catch(err) {
      console.log('ERROR! HighestLowestProductivityRatings chart container not found.')
      return(false)
    }

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
    var chart_container
    try {
      chart_container = this.container.querySelector('.chart_container')
    } catch(err) {
      console.log('ERROR! HighestLowestProductivityRatings chart container not found.')
      return(false)
    }

    chart_container.style.width = '99%'
    this.create_tables(chart_container)
    this.add_rows(this.data['highest'], 'highest')
    this.add_rows(this.data['lowest'], 'lowest')

  }

  create_tables(parent) {
    const tableContainer = document.createElement("div")
    tableContainer.style.display = "block"
    tableContainer.style.width = this.chart_width + 'px'
    /*tableContainer.style.height = this.chart_height + 'px'*/
    tableContainer.style.overflow = "auto"
    tableContainer.style.margin = "0 auto"

    let th, text, thead, row

    const leftColumn = document.createElement("div")
    leftColumn.classList.add("highest_lowest_left_column")
    leftColumn.style.width = "45%"
    leftColumn.style.float = "left"
    const highestTable = document.createElement("table")
    highestTable.setAttribute("id", "highest_productivity_rating_table")
    highestTable.classList.add("highest_lowest_table")
    thead = highestTable.createTHead()
    row = thead.insertRow()
    th = document.createElement("th")
    text = document.createTextNode(this.definition.labels['Highest'][this.locale])
    th.appendChild(text)
    row.appendChild(th)
    th = document.createElement("th")
    text = document.createTextNode(this.definition.labels['Rating'][this.locale])
    th.appendChild(text)
    row.appendChild(th)
    leftColumn.appendChild(highestTable)
    tableContainer.appendChild(leftColumn)

    const rightColumn = document.createElement("div")
    rightColumn.classList.add("highest_lowest_right_column")
    rightColumn.style.width = "45%"
    rightColumn.style.float = "right"
    const lowestTable = document.createElement("table")
    lowestTable.setAttribute("id", "lowest_productivity_rating_table")
    lowestTable.classList.add("highest_lowest_table")
    thead = lowestTable.createTHead()
    row = thead.insertRow()
    th = document.createElement("th")
    text = document.createTextNode(this.definition.labels['Lowest'][this.locale])
    th.appendChild(text)
    row.appendChild(th)
    th = document.createElement("th")
    text = document.createTextNode(this.definition.labels['Rating'][this.locale])
    th.appendChild(text)
    row.appendChild(th)
    rightColumn.appendChild(lowestTable)
    tableContainer.appendChild(rightColumn)

    parent.appendChild(tableContainer)

  }

  add_rows(data, column) {
    const table = document.getElementById(column + "_productivity_rating_table") 
    const table_body = table.createTBody()
    var background_color
    console.log(table)
    data.forEach((row, row_index) => {
      let table_row = table_body.insertRow()
      table_row.setAttribute("data-highestlowestcategory", column + "productivity")
      let cell0 = table_row.insertCell(0)
      cell0.innerHTML = row[0]
      let cell1 = table_row.insertCell(1)
      cell1.innerHTML = row[1]
    })
  }



}

export default HighestLowestProductivityRatings
