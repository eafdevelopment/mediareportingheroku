# Create DMU Leicester Castle
dmu_1 = Client.find_or_create_by(name: "DMU Leicester Castle Business School")

# DMU Leicester Castle on Facebook
dmu_1.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "act_1376049629358567"
).first_or_create

# DMU Leicester Castle on Twitter
dmu_1.client_channels.where(
  type: "ClientChannels::Twitter",
  uid: "hello_twitter_1"
).first_or_create

# Create DMU International
dmu_2 = Client.find_or_create_by(name: "DMU International")

# DMU International on Facebook
dmu_2.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "act_1406179109678952"
).first_or_create

# DMU International on Twitter
dmu_2.client_channels.where(
  type: "ClientChannels::Twitter",
  uid: "hello_twitter_2"
).first_or_create

# A DMU International campaign
dmu_2_campaign = dmu_2.campaigns.find_or_create_by(name: "An Example Campaign for DMU International")

# This campaign on DMU's Facebook
CampaignChannel.where(
  campaign_id: dmu_2_campaign.id,
  client_channel_id: dmu_2.client_channels.where(type: ClientChannels::Facebook).first.id,
  uid: "6063884630694"
).first_or_create

# Other Faceobok UIDs for testing and creating campaigns / campaign channels
# 6064123749960
# 6064039871360
# 6064123751360
# 6064123751160

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
