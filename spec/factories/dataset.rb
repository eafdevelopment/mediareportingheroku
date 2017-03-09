FactoryGirl.define do

  factory :dataset do
    sequence(:title) { |n| n }

    association :client_channel, factory: :client_channel
  end

end