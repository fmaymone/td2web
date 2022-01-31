import Report from './report.js'

const ReportInitializer= () => {
  new Report().render()
}

document.addEventListener('DOMContentLoaded', ReportInitializer)
