FactoryGirl.define do

  factory :rdf_class do
    id { Faker::Food.ingredient }
  end

end
