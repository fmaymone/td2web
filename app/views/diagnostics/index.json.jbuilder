# frozen_string_literal: true

json.array! @diagnostics, partial: 'diagnostics/diagnostic', as: :diagnostic
