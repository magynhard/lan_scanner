
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
    xml_results = []
    tmp_file = "#{Dir.tmpdir}/nmap_scan.xml"
    network.each do |n|
      ['-sL','-sn'].each do |nmap_type|
        `nmap #{nmap_type} #{n} -oX "#{tmp_file}"`
        xml_results.push File.read tmp_file
        File.delete tmp_file
      end
    end
    _parse_nmap_xml xml_results
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
      LanScanner::Device.new host_name: r.host_name, remote_address: r.remote_address
    end
  end
end