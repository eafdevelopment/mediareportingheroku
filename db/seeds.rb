# CLIENT: DMU International
# > Create
dmu_intl = Client.where(
  name: "DMU International - eight&four",
  google_analytics_view_id: "90647904"
).first_or_create
# > Facebook
dmu_intl.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "act_1406179109678952"
).first_or_create
# > AdWords
dmu_intl.client_channels.where(
  type: "ClientChannels::Adwords",
  uid: "752-213-4824"
).first_or_create
# > Instagram
dmu_intl.client_channels.where(
  type: "ClientChannels::Instagram",
  uid: "act_1406179109678952"
).first_or_create

# CLIENT: DMU (EU)
# > Create
dmu_eu = Client.where(
  name: "DMU (EU)",
  google_analytics_view_id: "90647904"
).first_or_create
# > Facebook
dmu_eu.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "act_1406179109678952" # Same as DMU International
).first_or_create
# > AdWords
dmu_eu.client_channels.where(
  type: "ClientChannels::Adwords",
  uid: "382-151-9617" 
).first_or_create
# > Instagram
dmu_eu.client_channels.where(
  type: "ClientChannels::Instagram",
  uid: "act_1406179109678952"
).first_or_create

# CLIENT: Dirty Martini
# > Create
dm = Client.where(
  name: "Dirty Martini",
  google_analytics_view_id: "75361758"
).first_or_create
# > Facebook
dm.client_channels.where(
  type: "ClientChannels::Facebook",
  uid: "act_1089006294443938"
).first_or_create
# > AdWords
dm.client_channels.where(
  type: "ClientChannels::Adwords",
  uid: "529-163-1130" 
).first_or_create
# > Instagram
dm.client_channels.where(
  type: "ClientChannels::Instagram",
  uid: "act_1089006294443938"
).first_or_create
