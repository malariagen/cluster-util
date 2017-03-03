require 'spec_helper'
describe 'sso_ldap_client' do
  context 'with default values for all parameters' do
    it { should contain_class('sso_ldap_client') }
  end
end
