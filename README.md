# lan_scanner
[![Gem](https://img.shields.io/gem/v/lan_scanner?color=default&style=plastic&logo=ruby&logoColor=red)](https://rubygems.org/gems/lan_scanner)
![downloads](https://img.shields.io/gem/dt/lan_scanner?color=blue&style=plastic)
[![License: MIT](https://img.shields.io/badge/License-MIT-gold.svg?style=plastic&logo=mit)](LICENSE)

> The very basic ruby gem to scan your LAN for devices

Based on nmap.

# Contents

* [Usage](#usage)
* [Installation](#installation)
* [Documentation](#documentation)
* [Contributing](#contributing)




<a name="usage"></a>
## Usage

### Find online devices in LAN
```ruby
require 'lan_scanner'

# examples with explicit default parameters
devices = LanScanner.scan_devices network: '192.168.178.0/24'
# => [LanScanner::Device, LanScanner::Device, ...]

devices.each do |d|
  puts "=================================================="
  puts "Found device on #{d.remote_address}"
  puts
  puts "Hostname: #{d.host_name}"
  puts
  # =================================================="
  # Found device on 192.168.178.20
  # 
  # Hostname: Windows-PC
  # 
end

```

### Get state of devices in LAN

```ruby
require 'lan_scanner'

devices = LanScanner.scan_device_states %w[192.168.178.1 192.168.178.22 192.168.178.44]
# => [LanScanner::Device, LanScanner::Device, ...]

devices.each do |d|
  puts "#{d.remote_address} -> #{d.host_name} (#{d.state})"
end
# 192.168.178.1 -> server.domain (up)
# 192.168.178.22 -> mycomputer.domain (up)
# 192.168.178.44 -> (down)
```

<a name="installation"></a>
## Installation

### NMAP

This gem is based on nmap. So you need to [install nmap](https://nmap.org/download.html) before and ensure it is available via command line (added to PATH environment variable).

To check if you have installed nmap correctly, run the following command on a terminal

```
nmap --version
```

and you should get some version information. After, you are ready to install the ruby gem.

### Gem

Add this line to your application's Gemfile:

```ruby
gem 'lan_scanner'
```

And then execute:

    $ bundle install

Or install it yourself by:

    $ gem install lan_scanner




  
<a name="documentation"></a>    
## Documentation
Check out the doc at RubyDoc
<a href="https://www.rubydoc.info/gems/lan_scanner">https://www.rubydoc.info/gems/lan_scanner</a>





<a name="contributing"></a>    
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/magynhard/lan_scanner. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

