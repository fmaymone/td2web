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
    end

    def errors?
      @errors.any?
    end

    def order
      return @order if @order.present?

      if (current_order = orders.active.first).present?
        @order = current_order
        return @order
      end

      @order = generate_order
    end

    def generate_order
      current_order = orders.new(
        user: @user,
        orderable: @team_diagnostic,
        payment_method: @payment_method,
        state: :pending
      )
      unless current_order.save
        @errors = current_order.errors.full_messages
        return current_order
      end
    end

    def submit_order
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

    def assign_items(order)
      OrderItem.transaction do
        order_products.each_with_index do |product_qty, index|
          product = product_qty[:product]
          item = order.order_items.new(
            index:,
            product: product,
            description: product.description,
            quantity: product_qty[:qty],
            unit_price: product.effective_price(product_qty[:qty])
          )
          unless item.save
            @errors = item.errors.full_messages
            raise ItemCreationError, 'Error adding items to the order'
          end
        end
      end
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
          product: product,
          id: pq[:id],
          qty: pq[:qty]
        }
      end

      products
    end

  end
end
