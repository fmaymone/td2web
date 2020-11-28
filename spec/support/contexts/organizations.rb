# frozen_string_literal: true

RSpec.shared_context 'organizations', shared_context: :metadate do
  include_context 'users'

  let(:organization) do
    service = OrganizationServices::Creator.new(
      user: facilitator,
      grantor: admin,
      params: attributes_for(:organization)
    )
    service.call
  end
  let(:organization2) do
    service = OrganizationServices::Creator.new(
      user: facilitator2,
      grantor: admin,
      params: attributes_for(:organization)
    )
    service.call
  end
end
