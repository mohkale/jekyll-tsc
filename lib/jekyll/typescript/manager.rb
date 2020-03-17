# frozen_string_literal: true

require 'singleton'
require 'fileutils'
require 'shellwords'
require_relative './config'
require_relative './tsconfig'
require_relative './mancache'

module Jekyll
  module Typescript
    # manages typescript
    class Manager
      SyntaxError = Class.new(ArgumentError)

      include ::Singleton
      include Config # jekyll config
      include TSConfig
      prepend ManagerCache

      # whether :ext is associated with a typescript extension.
      #
      def typescript_ext?(ext)
        ts_extensions.include? ext
      end

      # whether :ext is associated with an extension tsc will need
      # in the compilation directory, eg. .js
      #
      def copy_ext?(ext)
        typescript_ext?(ext) || copy_extensions.include?(ext)
      end

      # whether :page has a typescript extension.
      #
      def typescript_file?(page)
        typescript_ext? File.extname(page.name).downcase
      end

      # whether :page has a copy_file extension.
      #
      def copy_file?(page)
        copy_ext? File.extname(page.name).downcase
      end

      def setup
        unless @setup
          FileUtils.mkdir_p(temp_dir)
          @setup = true
        end
      end

      def static_files
        @static_files ||= []
      end

      attr_accessor :site, :pages

      # Typescript hook run before the site is rendered. This is used to reset
      # the typescript pages array and to assign the site instance used for the
      # compilation.
      #
      def pre_render(site, _)
        self.site = site
        @pages = []
      end

      # Typescript hook run after a page has been rendered. This is used to add a
      # a page to typescripts memory if that page is needed for typescript
      # compilation.
      #
      def add_page(page)
        @pages << page if copy_ext? page.ext
      end

      def page_to_output_path(page)
        # TODO only change the extension of .ts files.
        File.join(temp_dir,
                  File.dirname(page.relative_path),
                  File.basename(page.relative_path, '.*') + '.js')
      end

      # Once all the site files have been processed, compile and replace the content
      # of any typescript files.
      #
      def post_render(*args)
        setup

        Jekyll.logger.debug('Typescript', 'clearing out temporary build directory.')
        FileUtils.rm_rf(Dir.glob(File.join(temp_dir, '*')))

        populate_temp_dir
        @pages.select.each do |page|
          next unless typescript_ext? page.ext

          command = compile_command(in_temp_dir(page.relative_path))
          Jekyll.logger.debug('Typescript') {
            "running compile command: #{Shellwords.join(command[1..])}" }
          compile_output = IO.popen(command, &:read).chomp # spawn a cmd & read process output.

          unless $?.success?
            raise SyntaxError, "typescript failed to convert: #{page.path}\n" + compile_output
          end

          page.output = File.read(page_to_output_path(page))
        end
      end

      private

      # return :path but from the typescript temporary directory.
      #
      def in_temp_dir(path)
        File.join(temp_dir, path)
      end

      # copy all of the pages in pages to this plugins temporary directory.
      #
      def populate_temp_dir
        Dir.chdir(temp_dir) do
          (@pages + static_files).each do |page|
            if page.is_a?(StaticFile)
              FileUtils.mkdir_p('./' + page.instance_variable_get(:@dir))
              FileUtils.copy(site.in_source_dir(page.relative_path),
                             './' + page.relative_path)
            else
              FileUtils.mkdir_p('./' + page.dir) # make temp container for file
              File.open(page.relative_path, 'w') { |fd| fd.write(page.content) }
            end
          end
        end
      end

      # get a tsc compile command for use with popen, append :args to the end of it.
      #
      def compile_command(*args)
        [ENV, *tsc_command, '--pretty', '--rootDir', temp_dir, *tsconfig_args, *args]
      end

      # value of the tsconfig.json file as an array of command flags.
      #
      def tsconfig_args
        unless @tsconfig_args
          config_file = 'tsconfig.json'

          @tsconfig_args = if File.exist?(config_file)
                             parse_tsconfig(dumb_read_json(config_file))
                           else
                             Jekyll.logger.warn('Typescript', "no config file found at #{config_file}")
                             []
                           end
        end

        @tsconfig_args
      end

      Jekyll::Hooks.register(:site,  :pre_render,  &instance.method(:pre_render))
      Jekyll::Hooks.register(:pages, :post_render, &instance.method(:add_page))
      Jekyll::Hooks.register(:site,  :post_render, &instance.method(:post_render))
    end
  end
end
