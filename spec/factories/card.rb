# frozen_string_literal: true

FactoryBot.define do
  factory :card, class: 'Card' do
    sequence(:name)         { |n| "test_name_#{n}" }
    sequence(:email)        { |n| "test_email_#{n}" }
    person_id               { create(:person).id }
    sequence(:organization) { |n| "test_organization_#{n}" }
    sequence(:department)   { |n| "test_department_#{n}" }
    sequence(:title)        { |n| "test_title_#{n}" }
  end
end
