require 'spec_helper'

class String
  # inspired by groovy
  def strip_indent
    /^(?<blank> *)/.match(self) do |match|
      indent = match['blank'].size
      r = /^#{' ' * indent}/
      self.split("\n").map do |line|
        line.gsub(r, '')
      end.join("\n")
    end
  end
end

describe HomeAssistant::Generator::Automation do
  describe '.to_h' do
    it 'supports when trigger' do
      auto = HomeAssistant::Generator::Automation.new('supports simple when trigger') do
        trigger.when('kokodi').from(:idle).to(:playing)
      end
      expect(auto.to_h.to_yaml).to eq(<<-EOH.strip_indent + "\n")
      ---
      alias: supports simple when trigger
      trigger:
        entity_id: kokodi
        platform: state
        from: idle
        to: playing
      EOH
    end
  end
end
