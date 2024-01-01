
require 'socket'
require 'ostruct'
require 'tty-which'
require 'tmpdir'
require 'nokogiri'


require_relative 'lan_scanner/device'
require_relative 'lan_scanner/version'

module LanScanner

  # @return [Array<LanScanner::Device>] list of devices
  def self.scan_devices(network: nil)
    _ensure_nmap_available
    if network.nil?
      network = my_networks
    end
    network = [network] unless network.is_a? Array
    sn_xml_results = []
    tmp_file = "#{Dir.tmpdir}/nmap_scan_#{Random.random_number}.xml"
    # first we do an -sL scan, which also receives addresses from router/network cache,
    # that are not found by -sn scan when scanning for the complete network, but are found
    # with -sn scan, when scanning for this addresses explicitly
    #
    # so after this scan we scan for this addresses beneath the networks with -sn
    sl_xml_results = []
    network.each do |n|
      ['-sL'].each do |nmap_type|
        `nmap #{nmap_type} #{n} -oX "#{tmp_file}"`
        sl_xml_results.push File.read tmp_file
        File.delete tmp_file
      end
    end
    # here we scan for the received ip addresses from network cache
    sl_ips = _parse_nmap_xml sl_xml_results
    `nmap -sn #{sl_ips.map(&:remote_address).join(' ')} -oX "#{tmp_file}"`
    sn_xml_results.push File.read tmp_file
    # here we ping the networks (fast ping which does not detect all)
    network.each do |n|
      ['-sn'].each do |nmap_type|
        `nmap #{nmap_type} #{n} -oX "#{tmp_file}"`
        sn_xml_results.push File.read tmp_file
        File.delete tmp_file
      end
    end
    _parse_nmap_xml sn_xml_results
  end

  # get states of given addresses
  # @param [Boolean] expensive make expensive check for devices which were not found by fast check already
  def self.scan_device_states addresses, expensive: false
    addresses = [addresses] unless addresses.is_a? Array
    tmp_file = "#{Dir.tmpdir}/nmap_scan_#{Random.random_number}.xml"
    nmap_scan_option = if expensive
                   '-Pn'
                 else
                   '-sn'
                 end
    `nmap -sn #{addresses.join(' ')} -oX "#{tmp_file}"`
    online_hosts = _parse_nmap_xml [File.read(tmp_file)]
    offline_addresses = addresses.reject { |a| online_hosts.map(&:remote_address).include?(a) }
    # check offline addresses again with expensive check
    if expensive
      `nmap -sP #{offline_addresses.join(' ')} -oX "#{tmp_file}"`
      online_hosts += _parse_nmap_xml [File.read(tmp_file)]
      offline_addresses = addresses.reject { |a| online_hosts.map(&:remote_address).include?(a) }
    end
    online_hosts + offline_addresses.map { |a| OpenStruct.new(remote_address: a, host_name: nil, state: 'down') }
  end

  def self.my_networks
    my_ip_addresses.map do |a|
      if a.include?('.')
        a.split('.')[0..2].join('.') + '.0/24'
      else
        raise "No support for IPv6 devices"
      end
    end
  end

  def self.my_ip_addresses
    Socket.ip_address_list.select { |ai| ai.ipv4? && !ai.ipv4_loopback? }.map(&:ip_address).uniq
  end

  private

  def self._ensure_nmap_available
    unless TTY::Which.exist?("nmap")
      raise "Command 'nmap' not available. Ensure nmap is installed and added to your PATH variable. https://nmap.org'"
    end
  end

  def self._parse_nmap_xml(xml_contents)
    results = {} # use special hash to avoid duplicates easier
    xml_contents.each do |xml_data|
      xml_obj = Nokogiri::XML(xml_data)
      xml_obj.xpath('//nmaprun/host').each do |host|
        remote_address = host.at('address')['addr']
        host_name = host.at('hostnames/hostname')&.[]('name')
        state = host.at('status')&.[]('state')
        if !results.key?(remote_address) || (results.key?(remote_address) && host_name || state == 'up')
          old_host_name = results[remote_address]&.host_name
          results[remote_address] = OpenStruct.new(remote_address: remote_address, host_name: host_name || old_host_name, state: state)
        end
      end
    end
    puts
    results.values.select do |r|
      r.state == 'up' || r.host_name
    end.map do |r|
      LanScanner::Device.new host_name: r.host_name, remote_address: r.remote_address, state: r.state
    end
  end
end