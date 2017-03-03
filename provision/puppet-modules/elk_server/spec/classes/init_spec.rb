require 'spec_helper'
describe 'elk_server' do
  context 'with default values for all parameters' do
    it { should contain_class('elk_server') }
  end
end
