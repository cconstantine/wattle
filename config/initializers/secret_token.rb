# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Wattle::Application.config.secret_key_base = WatConfig.secret_value('SECRET_KEY_BASE') || Secret.secret_key_base || 'fcce71ed78631a4e47eea80bfa77727b91f6193e750aaa8f5d9e2817410bd6ecff973bb4bc405838fd5d22990ba7fcaac11a47d0b4a89462f7425c270a16b3c3'
