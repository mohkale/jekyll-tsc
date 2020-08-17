# frozen_string_literal: true

module Jekyll
  module Typescript
    # Module providing methods to aid in the parsing of tsconfig.json files.
    #
    module TSConfig
      # Parse a tsconfig.json JSON object into an array of equivalent commands
      # line flags.
      #
      # For some dumb reason, tsc just outright ignores your tsconfig.json file
      # when you're compiling a single file, instead of a project. See issue
      # 6591 on Microsoft/Typescript.
      #
      def parse_tsconfig(json)
        args = []
        json['compilerOptions'].each_pair do |option, value|
          flag = "--#{option}"

          case value
          when TrueClass, FalseClass
            args << flag if value
          when String
            args << flag
            args << value
          when Array
            args << flag
            args << value.join(',')
          else
            Jekyll.logger.warn('Typescript',
                               "unknown option type for #{option} of type #{value.class}")
          end
        end
        args
      end

      private

      # read a json file at :path, but allow for comments in the file.
      #
      def dumb_read_json(path)
        File.open(path, 'r') do |file|
          # regxp partially sourced from https://stackoverflow.com/questions/19910002/remove-comments-from-json-data
          JSON.parse(file.read.gsub(/(?:\/\/[^\n]+$)|(?:\/\*(?:[^*]+|\*+(?!\/))*\*\/)/m, ''))
        end
      end
    end
  end
end
