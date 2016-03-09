require 'simplecov'

SimpleCov.profiles.define 'ignore_vendor' do
  load_profile 'rails'
  add_filter 'vendor'
end
