# frozen_string_literal: true

module Jekyll
  module Typescript
    # Generator to ensure Manager is aware of any typescript (or related)
    # files it may need to process. This in affect forces typescript files
    # to be processed, even when they lack front matter.
    #
    class TypescriptGenerator < Jekyll::Generator
      def generate(site)
        @site = site
        Manager.instance.site ||= site
        Manager.instance.static_files.clear

        ts_files = []
        site.static_files.each do |file|
          if Manager.instance.typescript_file?(file)
            ts_files << file
          elsif Manager.instance.copy_file?(file)
            Manager.instance.static_files << file
          end
        end

        # turn any needed typescript files into regular pages.
        site.static_files -= ts_files
        site.pages += ts_files.map do |static_file|
          base = static_file.instance_variable_get('@base')
          dir  = static_file.instance_variable_get('@dir')
          name = static_file.instance_variable_get('@name')
          Jekyll::Page.new(@site, base, dir, name)
        end
      end
    end
  end
end
