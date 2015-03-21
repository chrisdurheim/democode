FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.safe_email }
    password { Faker::Internet.password(8) }
    password_confirmation { "#{password}" }
    organization
    role 'USER'
  end

  factory :admin, parent: :user do
    role 'ADMIN'
  end

  factory :user_thru_admin, class: User do
    name { Faker::Name.name }
    email { Faker::Internet.safe_email }
    role 'USER'
  end

  factory :admin_thru_admin, parent: :user_thru_admin do
    role 'ADMIN'
  end
end
