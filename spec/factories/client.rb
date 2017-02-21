FactoryGirl.define do 

  factory :client do
    sequence(:name) { |n| n }
  end
end