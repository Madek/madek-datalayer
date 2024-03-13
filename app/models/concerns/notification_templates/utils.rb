module Concerns
  module NotificationTemplates
    module Utils
      extend ActiveSupport::Concern

      class_methods do
        def vars_stub(vars, random_vals: false)
          vars.map { |v| v.split(".") }
            .reduce({}) do |r, x|
              val = ( random_vals ? random_val : nil )
              nested_hash = array_to_nested_hash(x, val)
              r.deep_merge(nested_hash)
            end
        end

        # [:foo, :bar, :baz] => { foo: { bar: { baz: val }}}
        def array_to_nested_hash(data, val = nil)
          if data.empty?
            val
          else
            head, *tail = data
            { head => array_to_nested_hash(tail, val) }
          end
        end

        def random_val
          random_length = rand(5..10)
          chars = ('a'..'z').to_a
          chars.shuffle.take(random_length).join
        end
      end
    end
  end
end
