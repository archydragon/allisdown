#!/usr/bin/env ruby -wKU
# encoding: utf-8

# # # Simple validator for config parameters

module Validate

  private

  ## String regular expression validator
  def self.validate(text, regexp)
    if text.scan(regexp).size == text.size
      true
    else
      false
    end
  end

  public

  ## Validate hostname
  def self.host?(str)
    # hostname shouldn't be nil and may contain only specific characters
    if str.nil? or !self.validate(str, /[a-zA-Z0-9\.\-_]/)
      false
    else
      true
    end
  end

  ## Validate timeout
  def self.timeout?(sec)
    # timeout is required too, and it should be number
    if sec.nil? or !self.validate(sec.to_s, /[0-9]/)
      false
    else
      true
    end
  end

  ## Validate port
  def self.port?(port_num, is_required = false)
    # port should be number, but it may be strongly required or not
    if !self.validate(port_num.to_s, /[0-9]/) or (port_num.nil? && is_required)
      false
    else
      true
    end
  end

  ## Validate iterations
  def self.iters?(count, is_required = false)
    # iterations should be number, but they may be strongly required or not
    if !self.validate(count.to_s, /[0-9]/) or (count.nil? && is_required)
      false
    else
      true
    end
  end

end
