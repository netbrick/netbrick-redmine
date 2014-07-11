require 'spec_helper'
describe 'redmine' do

  context 'with defaults for all parameters' do
    it { should contain_class('redmine') }
  end
end
