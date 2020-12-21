module HealthCards
  module CoreExt
    module Canonicalization
      def to_json_c14n
        puts 'ok'
        "{" + self.
          keys.
          sort_by {|k| k.to_s.encode(Encoding::UTF_16)}.
          map {|k| k.to_s.to_json_c14n + ':' + self[k].to_json_c14n}
                  .join(',') +
          '}'
      end
    end
  end
end


