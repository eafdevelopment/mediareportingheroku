# Create DMU Leicester Castle
dmu_1 = Client.where(
  name: "DMU - Leicester Castle Business School",
  google_analytics_view_id: ""
).first_or_create

# Create DMU International
dmu_2 = Client.where(
  name: "DMU International - eight&four",
  google_analytics_view_id: ""
).first_or_create

# Create De Montfort University Leicester (DMU)
dmu_3 = Client.where(
  name: "De Montfort University Leicester (DMU)",
  google_analytics_view_id: ""
).first_or_create

# DMU Leicester Castle on Facebook
dmu_1.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "act_1143706438973923"
).first_or_create

# DMU International on Facebook
dmu_2.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "act_1406179109678952"
).first_or_create

# De Montfort University on Facebook
dmu_3.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "act_1376049629358567"
).first_or_create

# De Montfort University campaigns
dmu_3_campaign_1 = dmu_3.campaigns.find_or_create_by(name: "recruitment_2017_facebook_acquisition_traffic_driving_video")
dmu_3_campaign_2 = dmu_3.campaigns.find_or_create_by(name: "2017_interview_remarketing_promoted_posts")
dmu_3_campaign_3 = dmu_3.campaigns.find_or_create_by(name: "conversion_remarketing_2017_instagram_traffic_driving")
dmu_3_campaign_4 = dmu_3.campaigns.find_or_create_by(name: "conversion_remarketing_2017_facebook_promoted_posts")
dmu_3_campaign_5 = dmu_3.campaigns.find_or_create_by(name: "recruitment_2017_facebook_acquisition_canvas_traffic_driving")
dmu_3_campaign_6 = dmu_3.campaigns.find_or_create_by(name: "recruitment_2017_facebook_acquisition_traffic_driving_image")
dmu_3_campaign_7 = dmu_3.campaigns.find_or_create_by(name: "Promoted Pages - Audience Generation")

# These campaigns on De Montfort University's Facebook
CampaignChannel.where(
  campaign_id: dmu_3_campaign_1.id,
  client_channel_id: dmu_3.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6066496188078",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_3_campaign_2.id,
  client_channel_id: dmu_3.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6065738876478",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_3_campaign_3.id,
  client_channel_id: dmu_3.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063185312278",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_3_campaign_4.id,
  client_channel_id: dmu_3.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063176740078",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_3_campaign_5.id,
  client_channel_id: dmu_3.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6061533889878",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_3_campaign_6.id,
  client_channel_id: dmu_3.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6056859080478",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_3_campaign_7.id,
  client_channel_id: dmu_3.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6028768937278",
  google_analytics_campaign_name: ""
).first_or_create

# Other Faceobok UIDs for testing and creating campaigns / campaign channels
# 6064123749960
# 6064039871360
# 6064123751360
# 6064123751160

# ------------------------------------------------------------------------------------- #

# Create Dirty Martini client
dm = Client.where(
  name: "Dirty Martini",
  google_analytics_view_id: "75361758"
).first_or_create

# Dirty Martini on Facebook
dm.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "1089006294443938"
).first_or_create

# A Dirty Martini campaign
dm_campaign = dm.campaigns.find_or_create_by(name: "always_on_london_celebrations_traffic_driving")

# This campaign on Dirty Martini's Facebook
CampaignChannel.where(
  campaign_id: dm_campaign.id,
  client_channel_id: dm.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6059092214976",
  google_analytics_campaign_name: "always_on_london_celebrations_traffic_driving"
).first_or_create

# Another Dirty Martini campaign
dm_campaign_2 = dm.campaigns.find_or_create_by(name: "always_on_cardiff_celebrations_traffic_driving")

# This campaign on Dirty Martini's Facebook
CampaignChannel.where(
  campaign_id: dm_campaign_2.id,
  client_channel_id: dm.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6059092214176",
  google_analytics_campaign_name: "always_on_cardiff_celebrations_traffic_driving"
).first_or_create
