FactoryGirl.define do

  factory :campaign_channel do
    sequence(:uid) { |n| n }

    association :campaign, factory: :campaign
    association :client_channel, factory: :client_channel
  end
end