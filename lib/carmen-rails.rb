require 'carmen'
require 'carmen/rails/action_view/form_helper'
require 'carmen/rails/version'

module Carmen
  module Rails
    class Railtie < ::Rails::Railtie
      # Add Carmen's locale paths to the Rails backend
      paths = Carmen.i18n_backend.locale_paths.map { |path|
        Dir[path + '**/*.yml']
      }.flatten.compact
      Carmen.i18n_backend = ::I18n
      config.i18n.load_path += paths

      # Enable fallbacks so that missing translations use the default locale
      config.i18n.fallbacks = true
    end
  end
end
