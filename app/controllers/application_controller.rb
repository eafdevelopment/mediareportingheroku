class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :basic_auth

  def basic_auth
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV["PRODUCTION_USERNAME"] && password == ENV["PRODUCTION_PASSWORD"]
      end
    end
  end

  def remove_ignored_uid_fields!(params)
    params.each do |k, v|
      if !v[:uid].present?
        params.delete k
      end
    end
  end
end
