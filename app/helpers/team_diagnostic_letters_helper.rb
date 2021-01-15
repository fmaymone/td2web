# frozen_string_literal: true

# TeamDiagnosticLettersHelper
module TeamDiagnosticLettersHelper
  def accordion_header(name:, expanded: false, btn_class: 'success', &block)
    accordion = "#{name}_accordion"
    section = "#{accordion}_section"
    header = "#{accordion}_header"
    data_target = "##{section}"
    content_tag(:div, id: header, class: 'card-header') do
      content_tag(:h2, class: 'mb-0') do
        content_tag(:button, class: "btn btn-#{btn_class}", type: 'button', data: { toggle: 'collapse', target: data_target }, aria: { expanded: expanded, section: section }, &block) +
          '&nbsp;'.html_safe +
          content_tag(:button, 'Add'.t, class: 'btn btn-primary btn-sm', type: 'button')
      end
    end
  end

  def accordion_section(name:, parent:, &block)
    accordion = "#{name}_accordion"
    section = "#{accordion}_section"
    header = "#{accordion}_header"
    # data_target = "##{section}"

    content_tag(:div, id: section, class: 'collapse', aria: { labeledby: header, parent: "##{parent}" }) do
      content_tag(:div, class: 'row card-body', &block)
    end
  end
end
