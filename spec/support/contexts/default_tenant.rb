# frozen_string_literal: true

RSpec.shared_context 'default_tenant', shared_context: :metadate do
  let(:default_tenant) { create(:tenant) }
end
