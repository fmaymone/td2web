# frozen_string_literal: true

# Dashboard/root Controller
class HomeController < ApplicationController
  def index
    @page_title = 'TeamDiagnostic Home'
  end
end
