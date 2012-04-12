require 'spec_helper'

class CarmenViewHelperTest < MiniTest::Unit::TestCase
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper
  include ActionDispatch::Assertions::SelectorAssertions

  def setup
    @object = OpenStruct.new
    def @object.to_s; 'object'; end
  end

  def response_from_page
    HTML::Document.new(@html).root
  end

  def test_basic_country_select
    html = country_select(@object, :country_code)
    expected = <<-HTML
      <select id="object_country_code" name="object[country_code]">
        <option value="OC">Oceania</option>
        <option value="EU">Eurasia</option>
        <option value="ES">Eastasia</option>
      </select>
    HTML

    assert_equal_markup(expected, html)
  end

  def test_country_selected_value
    @object.country_code = 'OC'
    @html = country_select(@object, :country_code)
    assert_select('option[selected="selected"][value="OC"]')
  end

  def test_basic_country_select_tag
    html = country_select_tag('attribute_name', nil)
    expected = <<-HTML
      <select id="attribute_name" name="attribute_name">
        <option value="OC">Oceania</option>
        <option value="EU">Eurasia</option>
        <option value="ES">Eastasia</option>
      </select>
    HTML

    assert_equal_markup(expected, html)
  end

  def test_country_tag_selected_value
    @html = country_select_tag(:country_code, 'OC')
    assert_select('option[selected="selected"][value="OC"]')
  end

  def test_priority_country_select
    html = country_select(@object, :country_code, {priority: ['ES']})
    expected = <<-HTML
      <select id="object_country_code" name="object[country_code]">
        <option value="ES">Eastasia</option>
        <option disabled>-------------</option>
        <option value="OC">Oceania</option>
        <option value="EU">Eurasia</option>
        <option value="ES">Eastasia</option>
      </select>
    HTML

    assert_equal_markup(expected, html)
  end

  def test_basic_subregion_select
    oceania = Carmen::Country.coded('OC')
    expected = <<-HTML
      <select id="object_subregion_code" name="object[subregion_code]"><option value="AO">Airstrip One</option></select>
    HTML

    html = subregion_select(@object, :subregion_code, oceania)

    assert_equal_markup(expected, html)
  end

  def test_subregion_select_using_parent_code
    expected = <<-HTML
      <select id="object_subregion_code" name="object[subregion_code]"><option value="AO">Airstrip One</option></select>
    HTML

    html = subregion_select(@object, :subregion_code, 'OC')

    assert_equal_markup(expected, html)
  end

  def test_subregion_select_using_parent_code_array
    expected = <<-HTML
      <select id="object_subregion_code" name="object[subregion_code]"><option value="LO">London</option></select>
    HTML

    html = subregion_select(@object, :subregion_code, ['OC', 'AO'])

    assert_equal_markup(expected, html)
  end

  def test_subregion_selected_value
    @object.subregion_code = 'AO'
    oceania = Carmen::Country.coded('OC')

    @html = subregion_select(@object, :subregion_code, oceania)

    assert_select('option[selected="selected"][value="AO"]')
  end

  def test_basic_subregion_select
    oceania = Carmen::Country.coded('OC')
    expected = <<-HTML
      <select id="subregion_code" name="subregion_code"><option value="AO">Airstrip One</option></select>
    HTML

    html = subregion_select_tag(:subregion_code, nil, oceania)

    assert_equal_markup(expected, html)
  end

  def method_missing(method, *args)
    fail "method_missing #{method}"
  end
end
