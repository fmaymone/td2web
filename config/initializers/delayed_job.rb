# frozen_string_literal: true

Delayed::Worker.queue_attributes = {
  high_priority: { priority: -10 },
  cable: { priority: 5 },
  mailers: { priority: 10 },
  messages: { priority: 10 },
  low_priority: { priority: 20 }
}
