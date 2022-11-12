# frozen_string_literal: true

module OrderServices
  class ItemCreationError < StandardError; end

  # Order management class
  class TeamDiagnosticOrder
    attr_reader :user, :orderable, :team_diagnostic, :payment_method, :errors

    def initialize(user:, orderable:, payment_method: :invoice, params: {})
      @user = user
      @orderable = @team_diagnostic = orderable
      @payment_method = payment_method
      @params = {}
      @errors = []
      @order = nil
    end

    def errors?
      @errors.any?
    end

    def order
      return @order if @order.present?

      current_order = @team_diagnostic.orders.active.order(created_at: :asc).first
      if current_order.present?
        @order = current_order
        return @order
      end

      generate
    end

    def finalize

    end

    def submit
      case order.state.to_sym
      when :pending
        # TODO
      when :finalized
        # TODO
      when :submitted
        # TODO
      when :paid
        # TODO
      else
        # TODO
      end
    end

    private

    def generate
      reset_errors

      new_order = Order.new(
        user: @user,
        orderable: @team_diagnostic,
        payment_method: @payment_method,
        state: :pending
      )
      if new_order.save
        assign_items(new_order)
        new_order.reload
      else
        @errors = new_order.errors.full_messages
      end
      @order = new_order
    end

    def assign_items(order)
      unless order.pending?
        @errors = ["Can't modify a finalized order"]
        return false
      end

      OrderItem.transaction do
        order_items = []
        order_products.each_with_index do |product_qty, index|
          product = product_qty[:product]
          item = OrderItem.new(
            order: order,
            index:,
            product:,
            description: product.description,
            quantity: product_qty[:qty],
            unit_price: product.effective_price(product_qty[:qty])
          )
          if item.save
            order_items << item
          else
            @errors = item.errors.full_messages
            raise ItemCreationError, 'Error adding items to the order'
          end
        end
      end
      order_items
    end

    def order_products
      # @params[:products] = [{ id: 'ABC', qty: 1}, ...]
      product_qtys = @params.fetch(:products, [])

      diagnostic_product = @team_diagnostic.diagnostic.product
      product_qtys << { id: diagnostic_product.id, product: diagnostic_product, qty: 1 }

      products = {}
      product_qtys.uniq.each do |pq|
        product = pq.fetch(:product, Product.active.find(pq[:id]))
        products[product.id] = {
          product:,
          id: pq[:id],
          qty: pq[:qty]
        }
      end

      products
    end

    def reset_errors
      @errors = []
    end
  end
end
