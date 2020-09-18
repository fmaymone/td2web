# frozen_string_literal: true

RSpec.shared_context 'default_tenant', shared_context: :metadate do
  let(:default_tenant) { Tenant.default_tenant || create(:tenant, slug: 'default') }
  before(:each) { default_tenant }
end
