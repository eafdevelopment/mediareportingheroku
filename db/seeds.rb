# Creating clients
dmu_1 = Client.find_or_create_by(name: 'DMU Leicester Castle Business School')
dmu_1.facebook_account_id = "act_1376049629358567"
dmu_1.save!

dmu_2 = Client.find_or_create_by(name: 'DMU International')
dmu_2.facebook_account_id = "act_1406179109678952"
dmu_2.save!

# Creating client channels
facebook_1 = Facebook.new(dmu_1)
facebook_2 = Facebook.new(dmu_2)

# Creating campaigns for an individual account  
facebook_1.fetch_campaigns
facebook_2.fetch_campaigns