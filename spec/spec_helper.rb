lib_path = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib_path)

require 'minitest/spec'
require 'minitest/autorun'

require 'action_view/test_case'

require 'rails'
require 'carmen-rails'
require 'ostruct'

MiniTest::Spec.register_spec_type(/.*/, ActionView::TestCase)

Carmen.clear_data_paths
Carmen.append_data_path(Carmen.root_path + 'spec_data/data')

locale_path = Carmen.root_path + 'spec_data/locale'
Carmen.i18n_backend = Carmen::I18n::Simple.new(locale_path)

class MiniTest::Unit::TestCase
  def assert_equal_markup(expected, actual, message=nil)
    assert_equal(clean_markup(expected), clean_markup(actual), message)
  end

  private

  def clean_markup(markup)
    markup.
      gsub(/\s+/, ' ').    # cleanup whitespace
      gsub(/>\s/, '>').    # kill space after tags
      gsub(/\s</, '<').    # space before tags
      gsub(/\s\/>/, '/>'). # space inside self-closing tags
      strip
  end
end
