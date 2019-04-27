require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

servers = File.foreach("../template/servers.csv")
ca = File.read("../static/ca.crt")
domain = "vpn.goldenfrog.com"

cfg = {
    ca: ca,
    frame: 1,
    compression: 1,
    ping: 10,
    eku: true
}

external = {
    hostname: "${id}.#{domain}"
}

recommended_cfg = cfg.dup
recommended_cfg["ep"] = ["UDP:443"]
recommended_cfg["cipher"] = "AES-256-GCM"

recommended = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: recommended_cfg,
    external: external
}
presets = [recommended]

defaults = {
    :username => "user@mail.com",
    :pool => "us",
    :preset => "default"
}

###

pools = []
servers.with_index { |line, n|
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

    pool = {
        :id => id,
        :country => country.upcase
    }
    if !area.nil?
        pool[:area] = area
    end
    pool[:hostname] = hostname
    pool[:addrs] = addresses
    pools << pool
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
