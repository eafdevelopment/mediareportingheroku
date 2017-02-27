class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :basic_auth

  protected

  # Internal: Filter through a set of nested attributes, removing them if
  # they have a blank UID.
  #
  # params - some nested params
  #
  # Example: 
  #
  # class MyController < ApplicationController
  #   before_action :remove_ignored_client_channel_uids
  #
  #   ...
  #
  #   private
  #   def remove_ignored_client_channel_uids
  #     remove_ignored_uid_fields! params[:client][:client_channels_attributes]
  #   end
  # end
  def remove_ignored_uid_fields!(params)
    params.each do |k, v|
      if !v[:uid].present?
        params.delete k
      end
    end
  end

  private

  def basic_auth
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV["PRODUCTION_USERNAME"] && password == ENV["PRODUCTION_PASSWORD"]
      end
    end
  end

end
