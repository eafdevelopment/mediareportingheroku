# Create DMU International
dmu_intl = Client.where(
  name: "DMU International - eight&four",
  google_analytics_view_id: "90647904"
).first_or_create

# DMU International on Facebook
dmu_intl.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "act_1406179109678952"
).first_or_create

# Create DMU (EU)
dmu_eu = Client.where(
  name: "DMU (EU)",
  google_analytics_view_id: "90647904"
).first_or_create

# DMU (EU) on Facebook
dmu_eu.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "act_1406179109678952" # Same as DMU International
).first_or_create

# DMU International campaigns
dmu_intl_campaign_1 = dmu_intl.campaigns.find_or_create_by(name: "offer_holders_sept_2017_promoted_post_remarketing")
dmu_intl_campaign_2 = dmu_intl.campaigns.find_or_create_by(name: "sept_2017_promoted_post_remarketing")
dmu_intl_campaign_3 = dmu_intl.campaigns.find_or_create_by(name: "all_markets_sept_2017_enquiry_remarketing_promoted_posts")
dmu_intl_campaign_4 = dmu_intl.campaigns.find_or_create_by(name: "egypt_sept_2017_recruitment_traffic driving")
dmu_intl_campaign_5 = dmu_intl.campaigns.find_or_create_by(name: "nigeria_sept_2017_recruitment_traffic driving")
dmu_intl_campaign_6 = dmu_intl.campaigns.find_or_create_by(name: "india_sept_2017_recruitment_traffic driving")
dmu_intl_campaign_7 = dmu_intl.campaigns.find_or_create_by(name: "pakistan_sept_2017_recruitment_traffic driving")
dmu_intl_campaign_8 = dmu_intl.campaigns.find_or_create_by(name: "thailand_sept_2017_recruitment_traffic driving")

# These campaigns on Facebook
CampaignChannel.where(
  campaign_id: dmu_intl_campaign_1.id,
  client_channel_id: dmu_intl.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063884630694",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_intl_campaign_2.id,
  client_channel_id: dmu_intl.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063884618094",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_intl_campaign_3.id,
  client_channel_id: dmu_intl.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063875073494",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_intl_campaign_4.id,
  client_channel_id: dmu_intl.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063533917094",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_intl_campaign_5.id,
  client_channel_id: dmu_intl.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063533821494",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_intl_campaign_6.id,
  client_channel_id: dmu_intl.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063533797494",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_intl_campaign_7.id,
  client_channel_id: dmu_intl.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063533863094",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_intl_campaign_8.id,
  client_channel_id: dmu_intl.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063533367694",
  google_analytics_campaign_name: ""
).first_or_create

# DMU (EU) campaigns
dmu_eu_campaign_1 = dmu_eu.campaigns.find_or_create_by(name: "uk_domicile_sept_2017_recruitment_traffic driving")
dmu_eu_campaign_2 = dmu_eu.campaigns.find_or_create_by(name: "romania_eu_2017_recruitment_traffic driving")
dmu_eu_campaign_3 = dmu_eu.campaigns.find_or_create_by(name: "greece_eu_2017_recruitment_traffic driving")
dmu_eu_campaign_4 = dmu_eu.campaigns.find_or_create_by(name: "bulgaria_eu_2017_recruitment_traffic driving")
dmu_eu_campaign_5 = dmu_eu.campaigns.find_or_create_by(name: "poland_eu_2017_recruitment_traffic driving")
dmu_eu_campaign_6 = dmu_eu.campaigns.find_or_create_by(name: "lithuania_eu_2017_recruitment_traffic driving")
dmu_eu_campaign_7 = dmu_eu.campaigns.find_or_create_by(name: "cyprus_eu_2017_recruitment_traffic driving")

# These campaigns on Facebook
CampaignChannel.where(
  campaign_id: dmu_eu_campaign_1.id,
  client_channel_id: dmu_eu.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6063533895894",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_eu_campaign_2.id,
  client_channel_id: dmu_eu.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6062746812894",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_eu_campaign_3.id,
  client_channel_id: dmu_eu.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6062746812294",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_eu_campaign_4.id,
  client_channel_id: dmu_eu.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6062746793294",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_eu_campaign_5.id,
  client_channel_id: dmu_eu.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6062746792894",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_eu_campaign_6.id,
  client_channel_id: dmu_eu.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6061752368094",
  google_analytics_campaign_name: ""
).first_or_create
CampaignChannel.where(
  campaign_id: dmu_eu_campaign_7.id,
  client_channel_id: dmu_eu.client_channels.find_by(type: ClientChannels::Facebook).id,
  uid: "6061748394694",
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
