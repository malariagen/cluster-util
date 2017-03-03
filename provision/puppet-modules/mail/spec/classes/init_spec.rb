require 'spec_helper'
describe 'mail' do
  context 'with default values for all parameters' do
    it { should contain_class('mail') }
  end
end
