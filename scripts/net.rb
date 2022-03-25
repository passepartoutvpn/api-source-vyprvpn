require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

template = File.foreach("../template/servers.csv")
ca = File.read("../static/ca.crt")
domain = "vpn.goldenfrog.com"

cfg = {
  ca: ca,
  cipher: "AES-256-GCM",
  compressionFraming: 1,
  compressionAlgorithm: 1,
  keepAliveSeconds: 10,
  keepAliveTimeoutSeconds: 60,
  checksEKU: false
}

recommended = {
  id: "default",
  name: "Default",
  comment: "256-bit encryption",
  ovpn: {
    cfg: cfg,
    endpoints: [
      "UDP:443"
    ]
  }
}
presets = [recommended]

defaults = {
  :username => "user@mail.com",
  :country => "US"
}

###

servers = []
template.with_index { |line, n|
  id, country, area = line.strip.split(",")
  id = id.downcase
  hostname = "#{id}.#{domain}"

  addresses = nil
  if ARGV.include? "noresolv"
    addresses = []
    #addresses = ["1.2.3.4"]
  else
    addresses = Resolv.getaddresses(hostname)
  end
  addresses.map! { |a|
    IPAddr.new(a).to_i
  }

  server = {
    :id => id,
    :country => country.upcase
  }
  if !area.nil?
    server[:area] = area
  end
  server[:hostname] = hostname
  server[:addrs] = addresses
  servers << server
}

###

infra = {
  :servers => servers,
  :presets => presets,
  :defaults => defaults
}

puts infra.to_json
puts
