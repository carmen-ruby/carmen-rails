require 'test_helper'

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
        <option value="ES">Eastasia</option>
        <option value="EU">Eurasia</option>
        <option value="OC">Oceania</option>
      </select>
    HTML

    assert_equal_markup(expected, html)
  end

  def test_country_selected_value
    @object.country_code = 'OC'
    @html = country_select(@object, :country_code)
    assert_select('option[selected="selected"][value="OC"]')
  end

  def test_country_selected_object_option
    @object.country_code = 'OC'
    override_object = OpenStruct.new(:country_code => 'ES')
    @html = country_select(@object, :country_code, {:object => override_object})

    assert_select('option[selected="selected"][value="ES"]')
  end

  def test_basic_country_select_tag
    html = country_select_tag('attribute_name', nil)
    expected = <<-HTML
      <select id="attribute_name" name="attribute_name">
        <option value="ES">Eastasia</option>
        <option value="EU">Eurasia</option>
        <option value="OC">Oceania</option>
      </select>
    HTML

    assert_equal_markup(expected, html)
  end

  def test_country_select_tag_with_prompt
    html = country_select_tag('attribute_name', nil, :prompt => 'Please Select')
    expected = <<-HTML
      <select id="attribute_name" name="attribute_name">
        <option value="">Please Select</option>
        <option value="ES">Eastasia</option>
        <option value="EU">Eurasia</option>
        <option value="OC">Oceania</option>
      </select>
    HTML

    assert_equal_markup(expected, html)
  end
  def test_country_tag_selected_value
    @html = country_select_tag(:country_code, 'OC')
    assert_select('option[selected="selected"][value="OC"]')
  end

  def test_priority_country_select
    html = country_select(@object, :country_code, :priority => ['ES'])
    expected = <<-HTML
      <select id="object_country_code" name="object[country_code]">
        <option value="ES">Eastasia</option>
        <option disabled>-------------</option>
        <option value="ES">Eastasia</option>
        <option value="EU">Eurasia</option>
        <option value="OC">Oceania</option>
      </select>
    HTML

    assert_equal_markup(expected, html)
  end

  def test_priority_country_select_deprecated_api
    html = country_select(@object, :country_code, ['ES'], {})
    expected = <<-HTML
      <select id="object_country_code" name="object[country_code]">
        <option value="ES">Eastasia</option>
        <option disabled>-------------</option>
        <option value="ES">Eastasia</option>
        <option value="EU">Eurasia</option>
        <option value="OC">Oceania</option>
      </select>
    HTML

    assert_equal_markup(expected, html)
  end

  def test_basic_subregion_select
    oceania = Carmen::Country.coded('OC')
    expected = <<-HTML
      <select id="object_subregion_code" name="object[subregion_code]">
        <option value="AO">Airstrip One</option>
      </select>
    HTML

    html = subregion_select(@object, :subregion_code, oceania)

    assert_equal_markup(expected, html)
  end

  def test_subregion_select_using_parent_code
    expected = <<-HTML
      <select id="object_subregion_code" name="object[subregion_code]">
        <option value="AO">Airstrip One</option>
      </select>
    HTML

    html = subregion_select(@object, :subregion_code, 'OC')

    assert_equal_markup(expected, html)
  end

  def test_subregion_select_using_parent_code_array
    expected = <<-HTML
      <select id="object_subregion_code" name="object[subregion_code]">
        <option value="LO">London</option>
      </select>
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

  def test_subregion_selected_value_with_priority_and_selected_options
    @object.subregion_code = 'AO'
    oceania = Carmen::Country.coded('OC')
    @html = subregion_select(@object, :subregion_code, oceania, { priority: ['AO'], selected: 'AO' })

    assert_select('option[selected="selected"][value="AO"]')  
  end

  def test_html_options_for_selected_value_with_priority_and_selected_options
    @object.subregion_code = 'AO'
    oceania = Carmen::Country.coded('OC')
    @html = subregion_select(@object, :subregion_code, oceania, { priority: ['AO'], selected: 'AO' }, { class: :test_html_options})

    assert_select('.test_html_options')
  end
  
  def test_basic_subregion_select_tag
    oceania = Carmen::Country.coded('OC')
    expected = <<-HTML
      <select id="subregion_code" name="subregion_code">
        <option value="AO">Airstrip One</option>
      </select>
    HTML

    html = subregion_select_tag(:subregion_code, nil, oceania)

    assert_equal_markup(expected, html)
  end

  def test_subregion_select_tag_with_priority
    oceania = Carmen::Country.coded('OC')
    expected = <<-HTML
      <select id="subregion_code" name="subregion_code">
        <option value="AO">Airstrip One</option>
        <option disabled>-------------</option>
        <option value="AO">Airstrip One</option>
      </select>
    HTML

    html = subregion_select_tag(:subregion_code, nil, oceania, :priority => ['AO'])

    assert_equal_markup(expected, html)
  end

  def test_subregion_select_tag_with_prompt
    oceania = Carmen::Country.coded('OC')
    expected = <<-HTML
      <select id="subregion_code" name="subregion_code">
        <option value="">Please select</option>
        <option value="AO">Airstrip One</option>
      </select>
    HTML

    html = subregion_select_tag(:subregion_code, nil, oceania, :prompt => 'Please select')

    assert_equal_markup(expected, html)
  end

  def test_region_options_for_select
    regions = Carmen::Country.all
    if Rails::VERSION::MAJOR == 3
      expected = <<-HTML
        <option value="ES">Eastasia</option>
        <option value="EU">Eurasia</option>
        <option value="OC" selected="selected">Oceania</option>
      HTML
    else
      expected = <<-HTML
        <option value="ES">Eastasia</option>
        <option value="EU">Eurasia</option>
        <option selected="selected" value="OC">Oceania</option>
      HTML
    end
    html = region_options_for_select(regions, 'OC')

    assert_equal_markup(expected, html)
  end

  def test_region_options_for_select_with_array_of_regions_and_priority
    regions = [Carmen::Country.coded('ES'), Carmen::Country.coded('EU')]
    expected = <<-HTML
      <option value="ES">Eastasia</option>
      <option disabled>-------------</option>
      <option value="ES">Eastasia</option>
      <option value="EU">Eurasia</option>
    HTML
    html = region_options_for_select(regions, nil, :priority => ['ES'])

    assert_equal_markup(expected, html)
  end

  def test_form_builder_country_select
    form = ActionView::Helpers::FormBuilder.new(:object, @object, self, {}, lambda{})

    html = form.country_select('attribute_name')
    expected = <<-HTML
      <select id="object_attribute_name" name="object[attribute_name]">
        <option value="ES">Eastasia</option>
        <option value="EU">Eurasia</option>
        <option value="OC">Oceania</option>
      </select>
    HTML

    assert_equal_markup(expected, html)
  end

  def test_form_builder_country_select_deprecated_api
    form = ActionView::Helpers::FormBuilder.new(:object, @object, self, {}, lambda{})

    html = form.country_select('attribute_name', ['ES'])
    expected = <<-HTML
      <select id="object_attribute_name" name="object[attribute_name]">
        <option value="ES">Eastasia</option>
        <option disabled>-------------</option>
        <option value="ES">Eastasia</option>
        <option value="EU">Eurasia</option>
        <option value="OC">Oceania</option>
      </select>
    HTML

    assert_equal_markup(expected, html)
  end
  
end
