# frozen_string_literal: true

module Orders
  # Order invoice helpers
  module Invoices
    extend ActiveSupport::Concern

    included do
      has_many :invoices, dependent: :destroy

      def allow_fulfillment?
        invoices.where(state: Invoice::PAID_STATES).any?
      end

      def active_invoice
        invoices
          .where(state: Invoice::ACTIVE_STATES)
          .order(created_at: :desc)
          .first
      end

      def submit_invoice
        calculate_total!
        return false unless valid?

        create_invoice
      end

      def create_invoice
        # Generate Invoice
        return active_invoice if active_invoice.present?

        invoice = Invoice.new(order: self, user:, subtotal:, tax:, total:, state: 'pending')
        return false unless invoice.save

        invoice.submit

        invoices.reload
        invoice
      end
    end
  end
end
