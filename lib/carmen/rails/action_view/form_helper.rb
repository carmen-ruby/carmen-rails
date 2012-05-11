module ActionView
  module Helpers
    module FormOptionsHelper

      # Return select and subregion option tags for the given object and method.
      #
      # Uses region_options_or_select to generate the list of option tags.
      def subregion_select(object, method, parent_region_or_code, options={}, html_options={})
        parent_region = determine_parent(parent_region_or_code)
        tag = InstanceTag.new(object, method, self, options.delete(:object))
        tag.to_region_select_tag(parent_region, options, html_options)
      end

      # Return select and country option tags for the given object and method.
      #
      # Uses region_options_or_select to generate the list of option tags.
      def country_select(object, method, options={}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_region_select_tag(Carmen::World.instance, options, html_options)
      end

      def region_options_for_select(parent_region, selected = nil, priority_region_codes)
        region_options = ""

        unless priority_region_codes.empty?
          priority_regions = priority_region_codes.map do |code|
            region = parent_region.subregions.coded(code)
            [region.name, region.code] if region
          end.compact
          unless priority_regions.empty?
            region_options += options_for_select(priority_regions, selected)
            region_options += "<option disabled>-------------</option>"
          end
        end

        main_options = parent_region.subregions.map { |r| [r.name, r.code] }
        main_options.sort!{|a, b| a.first.unpack('U').to_s <=> b.first.unpack('U').to_s}
        region_options += options_for_select(main_options, selected)
        region_options.html_safe
      end

      # Return select tag with the name provided containing country option
      # tags.
      #
      # Uses region_options_or_select to generate the list of option tags.
      def country_select_tag(name, value, options={})
        subregion_select_tag(name, value, Carmen::World.instance, options)
      end
      #
      # Return select tag with the name provided containing subregion option
      # tags.
      #
      # Uses region_options_or_select to generate the list of option tags.
      def subregion_select_tag(name, value, parent_region_or_code, options = {})
        options.stringify_keys!
        parent_region = determine_parent(parent_region_or_code)
        priority_regions = options.delete(:priority) || []
        opts = region_options_for_select(parent_region, value, priority_regions)
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
        opts = add_options(region_options_for_select(parent_region, value, priority_regions), options, value)
        content_tag("select", opts, html_options)
      end
    end

    class FormBuilder
      def country_select(method, options = {}, html_options = {})
        @template.country_select(@object_name, method,
                                 options.merge(:object => @object), html_options)
      end

      def subregion_select(method, parent_region_or_code, options={}, html_options={})
        @template.subregion_select(@object_name, method, parent_region_or_code,
                                   options.merge(:object => @object), html_options)
      end
    end

  end
end
