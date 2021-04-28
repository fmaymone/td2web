# frozen_string_literal: true

# == Schema Information
#
# Table name: report_template_pages
#
#  id                 :uuid             not null, primary key
#  report_template_id :uuid
#  slug               :string
#  index              :integer
#  locale             :string
#  format             :string
#  name               :string
#  markup             :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :report_template_page do
    report_template_id { '' }
    slug { 'MyString' }
    index { 1 }
    locale { 'MyString' }
    format { 'MyString' }
    name { 'MyString' }
    markup { 'MyText' }
  end
end
