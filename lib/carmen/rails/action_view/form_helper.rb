module ActionView
  module Helpers
    module FormOptionsHelper

      # Generate select and subregion option tags for the given object and method. A
      # common use of this would be to allow users to select a state subregion within
      # a given country.
      #
      # object       - The model object to generate the select for
      # method       - The attribute on the object
      # parent_region_or_code - An instance of Carmen::Region or a 2-character
      #                         country code.
      # options      - Other options pertaining to option tag generation. See
      #                `region_options_for_select`.
      # html_options - Options to use when generating the select tag- class,
      #                id, etc.
      #
      # Uses region_options_for_select to generate the list of option tags.
      #
      # Example:
      #
      #   subregion_select(@object, :region, {priority: ['US', 'CA']}, class: 'region')
      #
      # Returns an `html_safe` string containing the HTML for a select element.
      def subregion_select(object, method, parent_region_or_code, options={}, html_options={})
        parent_region = determine_parent(parent_region_or_code)
        tag = instance_tag(object, method, self, options)
        tag.to_region_select_tag(parent_region, options, html_options)
      end

      # Generate select and country option tags for the given object and method. A
      # common use of this would be to allow users to select a state subregion within
      # a given country.
      #
      # object       - The model object to generate the select for
      # method       - The attribute on the object
      # options      - Other options pertaining to option tag generation. See
      #                `region_options_for_select`.
      # html_options - Options to use when generating the select tag- class,
      #                id, etc.
      #
      # Uses region_options_or_select to generate the list of option tags.
      #
      # Example:
      #
      #   country_select(@object, :region, {priority: ['US', 'CA']}, class: 'region')
      #
      # Note that in order to preserve compatibility with various existing
      # libraries, an alternative API is supported but not recommended:
      #
      #   country_select(@object, :region, ['US', 'CA'], class: region)
      #
      # Returns an `html_safe` string containing the HTML for a select element.
      def country_select(object, method, priorities_or_options = {}, options_or_html_options = {}, html_options = {})
        if priorities_or_options.is_a? Array
          options = options_or_html_options
          options[:priority] = priorities_or_options
        else
          options = priorities_or_options
          html_options = options_or_html_options
        end

        tag = instance_tag(object, method, self, options)
        tag.to_region_select_tag(Carmen::World.instance, options, html_options)
      end

      # Generate option tags for a collection of regions.
      #
      # regions  - An array or Carmen::RegionCollection containing Carmen::Regions
      # selected - the code of the region that should be selected
      # options  - The hash of options used to customize the output (default: {}):
      #
      # To use priority regions (which are included in a special section at the
      # top of the list), provide an array of region codes at the :priority
      # option:
      #
      #   region_options_for_select(@region.subregions, 'US', priority: ['US', 'CA'])
      #
      # Returns an `html_safe` string containing option tags.
      def region_options_for_select(regions, selected=nil, options={})
        options.stringify_keys!
        priority_region_codes = options['priority'] || []
        region_options = ""

        unless priority_region_codes.empty?
          unless regions.respond_to?(:coded)
            regions = Carmen::RegionCollection.new(regions)
          end

          priority_regions = priority_region_codes.map do |code|
            region = regions.coded(code)
            [region.name, region.code] if region
          end.compact
          unless priority_regions.empty?
            region_options += options_for_select(priority_regions, selected)
            region_options += "<option disabled>-------------</option>"

            # If a priority region is selected, don't select it again in the main list.
            # This prevents some browsers from selecting the second occurance of this region,
            # which makes it difficult to select an alternative priority region.
            selected = nil if priority_region_codes.include?(selected)
          end
        end

        main_options = regions.map { |r| [r.name, r.code] }
        main_options.sort!{|a, b| a.first.to_s <=> b.first.to_s}
        main_options.unshift [options['prompt'], ''] if options['prompt']

        region_options += options_for_select(main_options, selected)
        region_options.html_safe
      end

      # Generate select and country option tags with the provided name. A
      # common use of this would be to allow users to select a country name
      # inside a web form.
      #
      # name         - The name attribute for the select element.
      # options      - Other options pertaining to option tag generation. See
      #                `region_options_for_select`.
      # html_options - Options to use when generating the select tag- class,
      #                id, etc.
      #
      # Uses region_options_or_select to generate the list of option tags.
      #
      # Example:
      #
      #   country_select_tag('country_code', {priority: ['US', 'CA']}, class: 'region')
      #
      # Returns an `html_safe` string containing the HTML for a select element.
      def country_select_tag(name, value, options={})
        subregion_select_tag(name, value, Carmen::World.instance, options)
      end

      # Generate select and subregion option tags for the given object and method. A
      # common use of this would be to allow users to select a state subregion within
      # a given country.
      #
      # name         - The name attribute for the select element.
      # parent_region_or_code - An instance of Carmen::Region or a 2-character
      #                         country code.
      # options      - Other options pertaining to option tag generation. See
      #                `region_options_for_select`.
      # html_options - Options to use when generating the select tag- class,
      #                id, etc.
      #
      # Uses region_options_or_select to generate the list of option tags.
      #
      # Example:
      #
      #   subregion_select_tag('state_code', 'US', {priority: ['US', 'CA']}, class: 'region')
      #
      # Returns an `html_safe` string containing the HTML for a select element.
      def subregion_select_tag(name, value, parent_region_or_code, options = {}, html_options = {})
        options.stringify_keys!
        parent_region = determine_parent(parent_region_or_code)
        opts = region_options_for_select(parent_region.subregions, value, options)
        html_options = {"name" => name,
                        "id" => sanitize_to_id(name)}.update(html_options.stringify_keys)
        content_tag(:select, opts, html_options)
      end

      private

      def instance_tag(object_name, method_name, template_object, options = {})
        if Rails::VERSION::MAJOR == 3
          InstanceTag.new(object_name, method_name, template_object, options.delete(:object))
        else
          ActionView::Helpers::Tags::Base.new(object_name, method_name, template_object, options || {})
        end
      end


      def determine_parent(parent_region_or_code)
        case parent_region_or_code
        when String
          Carmen::Country.coded(parent_region_or_code)
        when Array
          parent_region_or_code.inject(Carmen::World.instance) { |parent, next_code|
            parent.subregions.coded(next_code)
          }
        else
          parent_region_or_code
        end
      end
    end

    if Rails::VERSION::MAJOR == 3
      class InstanceTag
        def to_region_select_tag(parent_region, options = {}, html_options = {})
          html_options = html_options.stringify_keys
          add_default_name_and_id(html_options)
          priority_regions = options[:priority] || []
          value = options[:selected] ? options[:selected] : value(object)
          opts = add_options(region_options_for_select(parent_region.subregions, value, :priority => priority_regions), options, value)
          content_tag("select", opts, html_options)
        end
      end
    end

    if [4, 5, 6].include? Rails::VERSION::MAJOR
      module Tags
        class Base
          def to_region_select_tag(parent_region, options = {}, html_options = {})
            html_options = html_options.stringify_keys
            add_default_name_and_id(html_options)

            if (Rails::VERSION::MAJOR == 4 && !select_not_required?(html_options)) ||
               ([5, 6].include?(Rails::VERSION::MAJOR) && placeholder_required?(html_options))
              raise ArgumentError, "include_blank cannot be false for a required field." if options[:include_blank] == false
              options[:include_blank] ||= true unless options[:prompt]
            end

            value = options[:selected] ? options[:selected] : (method(:value).arity.zero? ? value() : value(object))
            priority_regions = options[:priority] || []
            opts = add_options(region_options_for_select(parent_region.subregions, value, 
                                                        :priority => priority_regions), 
                               options, value)
            select = content_tag("select", opts, html_options)
            if html_options["multiple"] && options.fetch(:include_hidden, true)
              tag("input", :disabled => html_options["disabled"], :name => html_options["name"], 
                           :type => "hidden", :value => "") + select
            else
              select
            end
          end
        end
      end
    end

    class FormBuilder
      # Generate select and country option tags with the provided name. A
      # common use of this would be to allow users to select a country name inside a
      # web form.
      #
      # See `FormOptionsHelper::country_select` for more information.
      def country_select(method, priorities_or_options = {}, options_or_html_options = {}, html_options = {})
        if priorities_or_options.is_a? Array
          options = options_or_html_options
          options[:priority] = priorities_or_options
        else
          options = priorities_or_options
          html_options = options_or_html_options
        end

        @template.country_select(@object_name, method, objectify_options(options), @default_options.merge(html_options))
      end

      # Generate select and subregion option tags with the provided name. A
      # common use of this would be to allow users to select a state subregion within
      # a given country.
      #
      # See `FormOptionsHelper::subregion_select` for more information.
      def subregion_select(method, parent_region_or_code, options = {}, html_options = {})
        @template.subregion_select(@object_name, method, parent_region_or_code, objectify_options(options), @default_options.merge(html_options))
      end
    end

  end
end
