# frozen_string_literal: true

require 'digest/md5'

module Jekyll
  module Typescript
    # caches files involved in typescript conversions, using their hash
    # and only start a new compilation if the result hash has changed
    # since the last compilation.
    #
    module ManagerCache
      def post_render(*args)
        if !cache_enabled?
          super
        elsif pages_modified?
          super
          update_cache
        else
          set_pages_from_cache
        end
      end

      private

      def pages_modified?
        # avoid comparing hashes and assume compilation has to happen when
        # there is no cache, or the number of files involved in the compilation
        # has changed.
        return true if conversion_cache.empty? ||
                       conversion_cache.size != pages.size + static_files.size

        (pages + static_files).each do |page|
          # no hash registered for the current file
          cached_hash = conversion_cache[page.relative_path]
          return true unless cached_hash

          # recompile when the output of compilation doesn't exist.
          return true unless File.exist?(page_to_output_path(page))

          # content of page has been modified.
          new_hash = Digest::MD5.hexdigest(get_content(page))
          return true if new_hash != cached_hash
        end

        false
      end

      def get_content(page)
        if page.is_a?(StaticFile)
          File.read(page.path)
        else
          page.content
        end
      end

      def update_cache
        @conversion_cache = {}

        (pages + static_files).each do |page|
          hash = Digest::MD5.hexdigest(get_content(page))
          conversion_cache[page.relative_path] = hash
        end

        nil
      end

      def set_pages_from_cache
        Jekyll.logger.debug('Typescript') {
          'restoring javascript files from compilation cache.' }

        pages.each { |page| page.output = File.read(page_to_output_path(page)) }
      end

      def conversion_cache
        @conversion_cache ||= {}
      end
    end
  end
end
