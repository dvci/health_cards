module Configuration
  class << self
    def key_path
      Rails.root.join(ENV.fetch 'KEY_PATH')
    end
  end
end