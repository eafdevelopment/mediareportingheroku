# Creating clients
dmu = Client.find_or_create_by(name: 'DMU')
christies = Client.find_or_create_by(name: 'Christies')
dmu.save!
christies.save!

# Creating client channels
facebook = ClientChannel.find_or_create_by(type: 'Facebook')
facebook.update(client: dmu, authentication: { access_key: "hello" })
facebook.save!

# Testing Facebook campaign API request
FacebookAds.access_token = ENV["FACEBOOK_ACCESS_TOKEN"]
# accounts = FacebookAds::AdAccount.all

# Creating campaigns for an individual account
dmu = FacebookAds::AdAccount.find("act_1376049629358567")
dmu_campaigns = dmu.ad_campaigns #(effective_status: nil)
sample_dmu_campaigns = dmu_campaigns.map{ |campaign| campaign.name }
sample_christies_campaigns = ['Christies 1', 'Christies 2', 'Christies 3']

sample_dmu_campaigns.each do |c|
  campaign = Campaign.find_or_create_by(name: c)
  campaign.client = Client.find_by(name: 'DMU')
  campaign.save!
end

sample_christies_campaigns.each do |c|
  campaign = Campaign.find_or_create_by(name: c)
  campaign.client = Client.find_by(name: 'Christies')
  campaign.save!
end
