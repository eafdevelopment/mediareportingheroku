module CampaignsHelper

  def uid_requirement(client_channel)
    channel = name(client_channel)
    if channel == 'Facebook'
      'Advert Set ID'
    else
      'Unique ID'
    end
  end
end
