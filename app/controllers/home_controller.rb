# frozen_string_literal: true

# Dashboard/root Controller
class HomeController < ApplicationController
  def index
    @page_title = 'TeamDiagnostic Home'
    @translations = Translation.limit(1000)
  end
end
