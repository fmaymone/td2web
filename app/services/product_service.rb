# frozen_string_literal: true

# Product Service
class ProductService
  class << self
    def product_for_diagnostic(diagnostic)
      case diagnostic.slug
      when Diagnostic::TDA_SLUG
        Product.where(slug: Product::TDA_REPORT).first
      when Diagnostic::TLV_SLUG
        Product.where(slug: Product::TLV_REPORT).first
      when Diagnostic::T360_SLUG
        Product.where(slug: Product::T360_REPORT).first
      when Diagnostic::ORG_SLUG
        Product.where(slug: Product::ORG_REPORT).first
      end
    end
  end

  def initialize(product: nil, team_diagnostic: nil)
    @team_diagnostic = team_diagnostic
    @product = product || ProductService.product_for_diagnostic(@team_diagnostic.diagnostic)
  end

  def purchase(payment_method = DEFAULT_PAYMENT_METHOD); end

  def submit_invoice; end
end
