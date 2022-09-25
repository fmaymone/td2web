class OpenEndedQuestions {
  constructor(locale, id, data) {
    this.chart_height = 600
    this.hpad = 20
    this.vpad = 20
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
    console.log('- Init OpenEnded Questions Report...')
    this.set_title()
    this.render_chart()
    console.log('- Init OpenEnded Questions Report [OK]')
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

  render_chart() {
    console.log('--- Start rendering of chart...')
    this.render_all_question_responses()
    console.log('--- Finished rendering of chart')
  }

  render_all_question_responses() {
    const question_ids = this.definition['labels']['_index']

    if (question_ids.length > 0) {
      const reference_container = this.container.cloneNode(true)
      var last_container = this.container
      var template = null

      question_ids.forEach((qid,index) => {
        console.log('Question: ', qid)
        if (index == 0) {
          this.render_question_responses(this.container, qid)
        } else {
          template = reference_container.cloneNode(true)
          template.id = this.container_id + index
          this.render_question_responses(template, qid)
          last_container.after(template)
          last_container = template
        }
      })
    } else {
      this.render_no_responses(this.container)
    }

  }

  render_question_responses(container, questionid) {
    const chart_container = container.querySelector('.chart_container')
    const question_text = this.definition['labels'][questionid][this.locale]

    const header = document.createElement('h2')
    header.classList.add('open_ended_question_header')
    header.innerHTML = question_text
    chart_container.appendChild(header)

    this.data['responses'][questionid].forEach((response) => {
      let response_container = document.createElement('p')
      response_container.classList.add('open_ended_question_response')
      response_container.innerHTML = response
      chart_container.appendChild(response_container)
    })
  }

  render_no_responses(container) {
    var header = document.createElement('h2')
    header.classList.add('open_ended_question_header')
    header.innerHTML = '---'

    var chart_container = container.querySelector('.chart_container')
    chart_container.appendChild(element)

    return(true)
  }

}

export default OpenEndedQuestions
