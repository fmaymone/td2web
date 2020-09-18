# frozen_string_literal: true

RSpec.shared_context 'grants', shared_context: :metadate do
  let(:entitlement) { create(:entitlement) }
end
