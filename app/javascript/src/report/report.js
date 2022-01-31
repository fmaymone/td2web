import ReportCharts from './report_charts.js'

class Report {
  constructor() {
    this.data = window.report_chart_data
    this.locale = window.report_locale
  }

  render() {
    ReportCharts.forEach( chartdef  => {
      console.log(chartdef)
      const chart_id = chartdef[0]
      const chart_class = chartdef[1]
      let chart = new chart_class(this.locale, chart_id, this.data[chart_id])
      chart.render()
    })
  }
}

export default Report
