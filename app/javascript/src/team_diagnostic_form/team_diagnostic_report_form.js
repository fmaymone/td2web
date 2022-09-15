import ReportPageOrder from './report_page_order.js'
import ReportVariations from './report_variations.js'

class TeamDiagnosticReportForm {
  constructor() {
    this.form = document.getElementById('report--options-form')
    this.report_variation = 'default'
  }

  render() {
    if (this.form === null) return(true)
      
    this.handle_form_submission()
    this.page_orderer = new ReportPageOrder('list--report_pages')
    this.report_variation_selector = new ReportVariations()
    console.log('- Rendered TeamDiagnosticReportForm')
  }

  handle_form_submission() {
    this.form.onsubmit = this.submit_form.bind(this)
  }

  submit_form(e) {
    e.preventDefault()
    console.log('DEBUG: submitting form')  
    let url = this.form.action
    let page_params = this.page_orderer.form_params()
    let variation_params = this.report_variation_selector.form_params()
    let authenticity_token = "authenticity_token=" + this.form.elements['authenticity_token'].value
    let query_string = `${page_params}&${variation_params}&${authenticity_token}`
    console.log('DEBUG: form action: ', url)
    console.log('DEBUG: query string: ', query_string)
    fetch(url, {
      method: "post",
      headers: { 'Content-Type': 'application/x-www-form-urlencoded'},
      body: query_string
  }).then(data =>  location.reload())
  }

}

const TeamDiagnosticReportFormInitializer = () => {
  new TeamDiagnosticReportForm().render()
}

export default TeamDiagnosticReportFormInitializer
