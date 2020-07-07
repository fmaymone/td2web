# frozen_string_literal: true

RSpec.shared_context 'default_organization', shared_context: :metadate do
  let(:default_organization) { create(:organization) }
end
