module LanScanner

  class Device
    attr_reader :host_name
    attr_reader :remote_address

    def initialize(remote_address:, host_name: nil)
      @host_name = host_name
      @remote_address = remote_address
    end
  end

end