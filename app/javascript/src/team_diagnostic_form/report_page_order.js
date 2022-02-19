class ReportPageOrder {
  constructor(container_id) {
    this.active_item = null
    this.container_id = container_id
    this.default_pages_selector_id = 'report_pages-selection_default_badge'
    this.custom_pages_selector_id = 'report_pages-selection_custom_badge'
    this.customization_component_id = 'report-page-selection'
    this.container = document.getElementById(this.container_id)
    this.component = document.getElementById(this.customization_component_id)
    const item_controls_query = `#${this.container_id} .list-group-item`
    this.item_controls = document.querySelectorAll(item_controls_query)
    this.page_order = this.scan_page_order()
    console.log('DEBUG: ', this.page_order)
    this.handle_events()
  }

  get_effective_page_order() {
    var pageorder = []
    this.item_controls.forEach(function(p){
      pageorder.push([parseInt(p.dataset.index), parseInt(p.dataset.pagenumber), p.dataset.active])
    })

    pageorder = pageorder
      .sort(function(a,b){ return(a[0] - b[0]) })
      .filter(function(p){ return(p[2] == 'true') })
      .map(function(p){ return(p[1]) })

    return(pageorder)
  }

  reset_page_order() {
    console.log('DEBUG: resetting page order')
    this.item_controls.forEach((item) => { item.dataset.active = 'true' })
    this.page_order = this.page_order.sort((a,b) => {
      return(parseInt(a) - parseInt(b))
    })
    console.log('DEBUG: ', this.page_order)
    return(this.page_order)
  }

  scan_page_order() {
    var pageorder = []
    this.item_controls.forEach((item) => {
      pageorder.push(item.dataset.pagenumber)
    }) 
    console.log('DEBUG: ', this.page_order)
    return(pageorder)
  }

  apply_page_order() {
    this.item_controls.forEach((item) => {
      let input = item.querySelector('input')
      let item_page = item.dataset.pagenumber
      let new_index = this.page_order.indexOf(item_page) + 1
      item.dataset.index = new_index
      item.style.order = new_index
      input.value = new_index
    })
  }

  insert_page_at_index(page, new_index, old_index) {
    let new_pageorder = []
    for(let i=1; i<=this.page_order.length; i++) {
      if (i==new_index) {
        new_pageorder.push(page)
        new_pageorder.push(this.page_order[i-1])
      } else if (i==old_index) {
        // NOOP
      } else {
        new_pageorder.push(this.page_order[i-1])
      }
    }
    this.page_order = new_pageorder
    console.log('DEBUG: ',this.page_order)
  }

  handle_events() {
    this.apply_page_selection_customizaton_selection_listeners()
    this.apply_drag_event_listeners()
    this.apply_page_toggle_listeners()
  }

  apply_page_selection_customizaton_selection_listeners(){
    document.getElementById(this.default_pages_selector_id).
      addEventListener('mouseup', this.default_pages_click_handler.bind(this))
    document.getElementById(this.custom_pages_selector_id).
      addEventListener('mouseup', this.custom_pages_click_handler.bind(this))
  }

  apply_drag_event_listeners() {
    this.item_controls.forEach((item) => {
      item.addEventListener('dragstart', this.dragstart_handler.bind(this))
      item.addEventListener('dragstart', this.dragstart_handler.bind(this))
      item.addEventListener('dragover', this.dragover_handler.bind(this))
      item.addEventListener('dragleave', this.dragleave_handler.bind(this))
      item.addEventListener('dragend', this.dragend_handler.bind(this))
      item.addEventListener('drop', this.drop_handler.bind(this))
    })
  }

  apply_page_toggle_listeners() {
    this.item_controls.forEach((item) => {
      item.querySelector('.list--control-select').
        addEventListener('mouseup', this.active_page_toggle_handler.bind(this))
    })
  }

  dragstart_handler(e) {
    e.dataTransfer.effectAllowed = 'move'

    const target = e.target
    target.classList.add('drag_click')
    this.active_item = target
  }

  dragend_handler(e) {
    const target = e.target
    target.classList.remove('drag_hover')
    this.item_controls.forEach((item) => {
      item.classList.remove('drag_hover')
      target.classList.remove('drag_click')
    })
  }

  dragover_handler(e) {
    e.preventDefault()

    const target = e.target
    target.classList.add('drag_hover')
    return false
  }

  dragleave_handler(e) {
    const target = e.target
    target.classList.remove('drag_hover')
    // NOOP
  }

  drop_handler(e) {
    e.stopPropagation()

    const target = e.target
    const new_index = target.dataset.index
    const pagenumber = this.active_item.dataset.pagenumber
    const current_index = this.active_item.dataset.index
    if(this.active_item != target) {
      this.insert_page_at_index(pagenumber, new_index, current_index)
      this.apply_page_order()
    }
    this.active_item = null

    return false
  }

  active_page_toggle_handler(e) {
    const target = e.target
    const parent = target.parentElement.parentElement
    if (parent.dataset.active == 'true') {
      this.disable_page(target)
    } else {
      this.enable_page(target)
    }
  }

  enable_page(el) {
    const parent = el.parentElement.parentElement
    parent.dataset.active = 'true'
    el.classList.add('badge-success')
    el.classList.remove('badge-secondary')
  }

  disable_page(el) {
    const parent = el.parentElement.parentElement
    parent.dataset.active = 'false'
    el.classList.remove('badge-success')
    el.classList.add('badge-secondary')
  }

  default_pages_click_handler(e) {
    const target = e.target
    const other_button = document.getElementById(this.custom_pages_selector_id)
    target.classList.remove('badge-light')
    target.classList.add('badge-info')
    other_button.classList.remove('badge-info')
    other_button.classList.add('badge-light')
    this.component.style.display = 'none'
    this.reset_page_order()
    this.apply_page_order()
    this.container.querySelectorAll('.list--control-select').forEach((item) => {
      this.enable_page(item)
    })
  }

  custom_pages_click_handler(e) {
    const target = e.target
    const other_button = document.getElementById(this.default_pages_selector_id)
    target.classList.remove('badge-light')
    target.classList.add('badge-info')
    other_button.classList.remove('badge-info')
    other_button.classList.add('badge-light')
    this.component.style.display = 'block'
  }

  form_params() {
    let query_string = ""
    let page_order = this.get_effective_page_order()
    if (page_order.length > 0) {
      query_string = "page_order[]=" + page_order.join('&page_order[]=')
    } else {
      // Select nothing? Get Everything!
      query_string = ""
    }
    return(query_string)
  }
}

export default ReportPageOrder
