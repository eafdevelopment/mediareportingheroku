# Create DMU Leicester Castle
dmu_1 = Client.find_or_create_by(name: "DMU Leicester Castle Business School")

# DMU Leicester Castle on Facebook
dmu_1.client_channels.create({
  type: "ClientChannels::Facebook",
  uid: "act_1376049629358567"
})

# DMU Leicester Castle on Google Analytics
# dmu_1.client_channels.create({
#   type: "ClientChannels::GoogleAnalytics",
#   uid: ""
# }) # ! we may not be using Google Analytics like this

# DMU Leicester Castle on Twitter
dmu_1.client_channels.create({
  type: "ClientChannels::Twitter",
  uid: "hello_twitter_1"
})

# Create DMU International
dmu_2 = Client.find_or_create_by(name: "DMU International")

# DMU International on Facebook
dmu_2.client_channels.create!({
  type: "ClientChannels::Facebook",
  uid: "act_1406179109678952"
})

# DMU International on Google Analytics
# dmu_2.client_channels.create({
#   type: "ClientChannels::GoogleAnalytics",
#   uid: "110182207"
# }) # ! we may not be using Google Analytics like this

# DMU International on Twitter
dmu_2.client_channels.create!({
  type: "ClientChannels::Twitter",
  uid: "hello_twitter_2"
})