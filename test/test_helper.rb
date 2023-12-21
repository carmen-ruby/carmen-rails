lib_path = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib_path)

require 'minitest/autorun'
require 'minitest/spec'

require 'action_view/test_case'

require 'rails'
require 'carmen-rails'
require 'ostruct'

Minitest::Spec.register_spec_type(/.*/, ActionView::TestCase)

Carmen.clear_data_paths

carmen_path = File.expand_path('..', __FILE__)

Carmen.append_data_path(carmen_path + '/spec_data/data')

locale_path = carmen_path + '/spec_data/locale'
Carmen.i18n_backend = Carmen::I18n::Simple.new(locale_path)

class Minitest::Test
  def assert_equal_markup(expected, actual, message = nil)
    assert_equal(clean_markup(expected), clean_markup(actual), message)
  end

  private

  def clean_markup(markup)
    clean_whitespace(markup).gsub(/( [a-zA-Z_]*="[^"]*")+/) do |match|
      ' ' + match.strip!.split(' ').sort.join(' ')
    end
  end

  def clean_whitespace(markup)
    markup.
      gsub(/\s+/, ' ').    # cleanup whitespace
      gsub(/>\s/, '>').    # kill space after tags
      gsub(/\s</, '<').    # space before tags
      gsub(/\s\/>/, '/>'). # space inside self-closing tags
      strip
  end
end
