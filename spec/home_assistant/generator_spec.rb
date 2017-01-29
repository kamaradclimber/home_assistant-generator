require 'spec_helper'

describe HomeAssistant::Generator do
  it 'has a version number' do
    expect(HomeAssistant::Generator::VERSION).not_to be nil
  end
end
