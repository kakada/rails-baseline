# frozen_string_literal: true

require "timecop"

def within_same_period(&block)
  Timecop.freeze(&block)
end
