# Reports Controller  displays all the reports stored on AWS with download links

class ReportsController < ApplicationController

  def index
    @reports = Dataset.all.order(created_at: :desc)
    @generating = Dataset.all.where(status: 'generating')
  end
end
