FactoryGirl.define do 

  factory :client_channel do
    sequence(:type) { |n| "ClientChannels::#{n}" }
    sequence(:uid) { |n| "act_#{n}" }

    association :client, factory: :client
  end
end