
module Dnet
  module Util
    def self.unhexify(str, d=/\s*/)
      str.to_s.strip.gsub(/([A-Fa-f0-9]{1,2})#{d}?/) { $1.hex.chr }
    end

  end
end
