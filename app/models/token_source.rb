class TokenSource
  def generate
    SecureRandom.hex(20)
  end
end
