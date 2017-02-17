module CampaignChannelsHelper
  def campaign_channel_human_readable_name(campaign_channel)
    campaign_channel.client_channel.class.name.split('::').last
  end
end