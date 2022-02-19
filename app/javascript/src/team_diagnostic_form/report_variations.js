class ReportVariations {
  constructor() {
    this.variation = 'default'
    console.log('-- Initialized ReportVariations')
  }

  form_params() {
    let query_string = ""
    query_string = query_string + `report_variation=${this.variation}`
    return(query_string)
  }

}

export default ReportVariations
