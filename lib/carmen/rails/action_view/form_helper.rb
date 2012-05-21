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
      # Uses region_options_or_select to generate the list of option tags.
      #
      # Example:
      #
      #   subregion_select(@object, :region, {priority: ['US', 'CA']}, class: 'region')
      #
      # Returns an `html_safe` string containing the HTML for a select element.
      def subregion_select(object, method, parent_region_or_code, options={}, html_options={})
        parent_region = determine_parent(parent_region_or_code)
        tag = InstanceTag.new(object, method, self, options.delete(:object))
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
      # Returns an `html_safe` string containing the HTML for a select element.
      def country_select(object, method, options={}, html_options={})
        tag = InstanceTag.new(object, method, self, options.delete(:object))
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
          end
        end

        main_options = regions.map { |r| [r.name, r.code] }
        main_options.sort!{|a, b| a.first.unpack('U').to_s <=> b.first.unpack('U').to_s}
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
        priority_regions = options.delete(:priority) || []
        opts = region_options_for_select(parent_region.subregions, value, :priority => priority_regions)
        html_options = {"name" => name,
                        "id" => sanitize_to_id(name)}.update(options.stringify_keys)
        content_tag(:select, opts, html_options)
      end

      private

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

    class InstanceTag
      def to_region_select_tag(parent_region, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        priority_regions = options[:priority] || []
        value = value(object)
        opts = add_options(region_options_for_select(parent_region.subregions, value, :priority => priority_regions), options, value)
        content_tag("select", opts, html_options)
      end
    end

    class FormBuilder
      # Generate select and country option tags with the provided name. A
      # common use of this would be to allow users to select a country name inside a
      # web form.
      #
      # See `FormOptionsHelper::country_select` for more information.
      def country_select(method, options = {}, html_options = {})
        @template.country_select(@object_name, method,
                                 options.merge(:object => @object), html_options)
      end

      # Generate select and subregion option tags with the provided name. A
      # common use of this would be to allow users to select a state subregion within
      # a given country.
      #
      # See `FormOptionsHelper::subregion_select` for more information.
      def subregion_select(method, parent_region_or_code, options={}, html_options={})
        @template.subregion_select(@object_name, method, parent_region_or_code,
                                   options.merge(:object => @object), html_options)
      end
    end

  end
end
