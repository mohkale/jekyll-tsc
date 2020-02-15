# frozen_string_literal: true

module Jekyll
  module Typescript
    # This class just makes jekyll change the extensions of any typescript
    # files to .js.
    #
    # To see where the actual conversion takes place, see ./manager.rb
    class TypescriptConverter < Jekyll::Converter
      priority :low

      def matches(ext)
        Manager.instance.typescript_ext?(ext)
      end

      def output_ext(_)
        '.js'
      end

      def convert(content)
        content
      end
    end
  end
end
