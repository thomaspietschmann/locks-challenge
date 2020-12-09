class ReportsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_server

  def handle
    if Rails.env.development?
      Entry.delete_all
      Lock.delete_all
    end

    # process the CSV file sent in the request
    report = params[:report].open
    require 'csv'

    csv_options = { col_sep: ',', headers: :first_row }
    CSV.foreach(report, csv_options) do |timestamp, lock_id, kind, status_change|
      lock = Lock.find_by_id(lock_id[1])
      if lock
        lock.status = status_change[1]
        lock.save
      else
        lock = Lock.create(id: lock_id[1], kind: kind[1], status: status_change[1])
      end
      Entry.create(timestamp: timestamp[1], status_change: status_change[1], lock: lock)
    end

    render json: { message: "Your report has been saved. Now you have #{Lock.count} locks and #{Entry.count} entries." }
  end

  def authenticate_server
    code_name = request.headers['X-Server-CodeName']
    token = request.headers['X-Server-Token']
    server = Server.find_by(code_name: code_name)
    render json: { message: 'wrong credentials' } unless server && token == server.access_token
  end
end
