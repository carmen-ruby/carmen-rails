require 'minitest/spec'
require 'minitest/autorun'

lib_path = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib_path)

require 'active_support'
require 'action_view'
require 'action_controller'
require 'action_view/test_case'
require 'carmen'
require 'carmen-rails'
require 'ostruct'

require 'yaml'
YAML::ENGINE.yamler = 'syck'

MiniTest::Spec.register_spec_type(/.*/, ActionView::TestCase)

Carmen.data_path = Carmen.root_path + '/spec/data'
puts Carmen.data_path

locale_path = Carmen.root_path + '/spec/locale'
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
