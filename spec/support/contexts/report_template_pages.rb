# frozen_string_literal: true

RSpec.shared_context 'report_template_pages', shared_context: :metadate do
  include_context 'report_templates'

  let(:team_diagnostic_report_template_html_layout) do
    create(:report_template_page,
           report_template: teamdiagnostic_report_template,
           slug: 'layout',
           index: 0,
           locale: 'en',
           format: 'html',
           name: 'Team Diagnostic Report Template (en)',
           markup: <<~LAYOUT
              <html>
                <head>
                  <title>Team Diagnostic Report</title>
                </head>
                <body>
                  diagnostic_type: {{ diagnostic_type }}
                  team_name: {{ team_name }}
                  locale: {{ locale }}
                  organization: {{ organization }}
                  tenant: {{ tenant }}
                  /// Pack Tags Here
                  [[PACK_TAGS_HERE]]
                  /// End Pack Tags
                  Begin Layout
                  /// Report Content Pages Here
                  [[REPORT_CONTENT_HERE]]
                  /// End Content
                  End Layout  
                </body>
             </html>
           LAYOUT
          )
  end

  let(:team_diagnostic_report_template_html_page_1) do
    create(:report_template_page,
           report_template: teamdiagnostic_report_template,
           slug: 'page1',
           index: 1,
           locale: 'en',
           format: 'html',
           name: 'Team Diagnostic Report Page 1 (en)',
           markup: <<~LAYOUT
             Page 1 : Out as page {{ page }}
           LAYOUT
          )
  end

  let(:team_diagnostic_report_template_html_page_2) do
    create(:report_template_page,
           report_template: teamdiagnostic_report_template,
           slug: 'page2',
           index: 2,
           locale: 'en',
           format: 'html',
           name: 'Team Diagnostic Report Page 2 (en)',
           markup: <<~LAYOUT
             Page 2 : Out as page {{ page }}
           LAYOUT
          )
  end

  let(:team_diagnostic_report_template_html_layout_es) do
    create(:report_template_page,
           report_template: teamdiagnostic_report_template,
           slug: 'layout',
           index: 0,
           locale: 'es',
           format: 'html',
           name: 'Team Diagnostic Report Template (es)',
           markup: <<~LAYOUT
              <html>
                <head>
                  <title>Team Diagnostic Report</title>
                </head>
                <body>
                  diagnostic_type: {{ diagnostic_type }}
                  team_name: {{ team_name }}
                  locale: {{ locale }}
                  organization: {{ organization }}
                  tenant: {{ tenant }}
                  /// Pack Tags Here
                  [[PACK_TAGS_HERE]]
                  /// End Pack Tags
                  Begin Layout ES
                  /// Report Content Pages Here
                  [[REPORT_CONTENT_HERE]]
                  /// End Content
                  End Layout  
                </body>
             </html>
           LAYOUT
          )
  end

  let(:team_diagnostic_report_template_html_page_1_es) do
    create(:report_template_page,
           report_template: teamdiagnostic_report_template,
           slug: 'page1',
           index: 1,
           locale: 'es',
           format: 'html',
           name: 'Team Diagnostic Report Page 1 (es)',
           markup: <<~LAYOUT
             Page 1 ES : Out as page {{ page }}
           LAYOUT
          )
  end

  let(:team_diagnostic_report_template_html_page_2_es) do
    create(:report_template_page,
           report_template: teamdiagnostic_report_template,
           slug: 'page2',
           index: 2,
           locale: 'es',
           format: 'html',
           name: 'Team Diagnostic Report Page 2 (es)',
           markup: <<~LAYOUT
             Page 2 ES : Out as page {{ page }}
           LAYOUT
          )
  end

  before(:each) do
    teamdiagnostic_report_template
    team_diagnostic_report_template_html_layout
    team_diagnostic_report_template_html_page_1
    team_diagnostic_report_template_html_page_2
    team_diagnostic_report_template_html_layout_es
    team_diagnostic_report_template_html_page_1_es
    team_diagnostic_report_template_html_page_2_es
  end
end
