FactoryGirl.define do 

  factory :campaign do
    sequence(:name) { |n| n }

    association :client, factory: :client
  end
  
end