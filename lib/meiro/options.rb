module Meiro
  class Options
    class << self
      attr_reader :keys, :validators

      def option(symbol, klass, default=nil, check=nil)
        @keys ||= []
        @keys << symbol
        @validators ||= {}
        @validators[symbol] ||= {}
        @validators[symbol][:class] = klass
        @validators[symbol][:check] = check if check && check.kind_of?(Proc)
        define_method(symbol) do
          option_value = @config[symbol] ||
            (default.kind_of?(Proc) ? default.call(self) : default)
          @applied_config[symbol] = option_value
        end
      end
    end

    def initialize(config)
      @config = validate(config)
      @applied_config = {}
    end

    def keys
      self.class.keys
    end

    private

    def validate(config)
      validate_keys(config)
      validate_values(config)
      config
    end

    def validate_keys(config)
      valid_symbols = self.class.keys
      config.each_key do |k|
        raise "Invalid option: #{k}" unless valid_symbols.include? k
      end
    end

    def validate_values(config)
      validators = self.class.validators
      config.each do |k, v|
        klass = validators[k][:class]
        proc = validators[k][:check] || lambda {|v, config| true }
        unless v.kind_of?(klass) && proc.call(v, config)
          raise "Invalid option: #{k}(#{klass}) => #{v}"
        end
      end
    end
  end
end
