dmu = Client.find_or_create_by(name: 'DMU')
christies = Client.find_or_create_by(name: 'Christies')
dmu.save!
christies.save!

facebook = ClientChannel.find_or_create_by(type: 'Facebook')
facebook.update(client: dmu) #, authentication: { access_key: "hello" })
facebook.save!

sample_dmu_campaigns = ['DMU Campaign 1', 'DMU Campaign 2', 'DMU Campaign 3']
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
