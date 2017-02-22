class CampaignChannelsController < ApplicationController

  def index
    # this route receives AJAX $.get requests to update
    # the New Report form fields on home#index
    @campaign_channels = CampaignChannel.where(campaign_id: params[:campaign_id])
    respond_to do |format|
      format.js
    end
  end

end
