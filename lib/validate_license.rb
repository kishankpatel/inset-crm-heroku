require 'openssl'
class ValidateLicense
  CNAME = 'aes-256-cbc'
  CIV = ['1e5673b2572af26a8364a50af84c7d2a'].pack('H*')
  attr_reader :k,:d

  def initialize(k,d);@k = k;@d = d;end  

  def decrypt;c = OpenSSL::Cipher::Cipher.new(CNAME).decrypt;c.iv = CIV;c.key = @k;c.update([@d].pack('H*')) + c.final;end

  def encrypt;c = OpenSSL::Cipher::Cipher.new(CNAME).encrypt;c.iv = CIV;c.key = @k;(c.update("#{@d}") + c.final).unpack('H*')[0];end
  
end

