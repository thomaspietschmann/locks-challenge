class ReportsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def handle
    p request.headers['X-Server-CodeName']
    p request.headers['X-Server-Token']
    render json: { message: 'testing' }
  end
end
