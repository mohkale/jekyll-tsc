# frozen_string_literal: true

module Jekyll
  module Typescript
    # module adding methods to access the config variables for this
    # plugin from the users _config.yml.
    #
    # these methods are also expected to attach the default values for
    # these options should they be unassigned.
    #
    module Config
      def ts_extensions
        @ts_extensions ||= Array(config['extensions']) || %w[.ts .tsx]
      end

      def copy_extensions
        @copy_extensions ||= Array(config['copy_ext']) || []
      end

      def temp_dir
        @temp_dir ||= config['temp_dir'] || '.typescript'
      end

      def tsc_command
        @tsc_command ||= Array(config['command']) || ['tsc']
      end

      private

      def config
        @config ||= site.config['typescript'] || {}
      end
    end
  end
end
