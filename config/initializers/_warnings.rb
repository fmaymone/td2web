if Rails.env.test?
  Warning[:deprecated] = proc { |message, callstack|
    raise message
  }
end
