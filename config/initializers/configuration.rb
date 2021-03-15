# frozen_string_literal: true

# Central location to get configuration details
module Configuration
  class << self
    def key_path
      Rails.root.join(ENV.fetch('KEY_PATH'))
    end
  end
end
