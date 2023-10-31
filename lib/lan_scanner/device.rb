module LanScanner

  class Device
    attr_reader :host_name
    attr_reader :remote_address
    attr_reader :state # 'up','down','unknown'

    def initialize(remote_address:, host_name: nil, state: nil)
      @host_name = host_name
      @remote_address = remote_address
      @state = state
    end
  end

end