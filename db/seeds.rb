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