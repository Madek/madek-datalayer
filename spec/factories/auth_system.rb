FactoryBot.define do
  factory :auth_system do
    type {"external"}
    name {Faker::Name.unique.name}
    id {"auth-sys_#{name.downcase.gsub(/[^a-z]/,'-') }"}

    transient do
      internal_key { Madek::Crypto::ECKey.new }
      external_key { Madek::Crypto::ECKey.new }
    end

    internal_private_key { internal_key.private_key }
    internal_public_key { internal_key.public_key }

    external_public_key { external_key.public_key }
  end
end
