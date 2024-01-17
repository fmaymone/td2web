# app/controllers/errors_controller.rb
class ErrorsController < ApplicationController
  def show
    render status: params[:code]
  end
end
