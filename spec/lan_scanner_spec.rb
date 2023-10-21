require 'spec_helper'
require 'lan_scanner'

#----------------------------------------------------------------------------------------------------

RSpec.describe LanScanner do
  it "has a version number" do
    expect(LanScanner::VERSION).not_to be nil
  end
end

#----------------------------------------------------------------------------------------------------
