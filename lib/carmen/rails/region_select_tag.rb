module Carmen
  module Rails
    module RegionSelectTag
      def to_region_select_tag(parent_region, options = {}, html_options = {})
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        if (::Rails::VERSION::MAJOR == 4 && !select_not_required?(html_options)) ||
           ([5, 6, 7].include?(::Rails::VERSION::MAJOR) && placeholder_required?(html_options))
          raise ArgumentError, 'include_blank cannot be false for a required field.' if options[:include_blank] == false

          options[:include_blank] ||= true unless options[:prompt]
        end

        value = options[:selected] ? options[:selected] : (method(:value).arity.zero? ? value() : value(object))
        priority_regions = options[:priority] || []
        opts = add_options(region_options_for_select(parent_region.subregions, value,
                                                     priority: priority_regions),
                           options, value)
        select = content_tag('select', opts, html_options)
        if html_options['multiple'] && options.fetch(:include_hidden, true)
          tag('input', disabled: html_options['disabled'], name: html_options['name'],
                       type: 'hidden', value: '') + select
        else
          select
        end
      end
    end
  end
end
