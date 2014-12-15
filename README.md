# NOT ACTIVELY MAINTAINED

I haven't time in over a year to properly support this project.

# carmen-rails

carmen-rails is a Rails 3 plugin that supplies two new form helper methods:
`country_select` and `subregion_select`. It uses
[carmen](http://github.com/jim/carmen) as its source of geographic data.

## Requirements

carmen-rails requires Ruby 1.9.2 or greater.

## Installation

Just add carmen-rails to your Gemfile:

```ruby
gem 'carmen-rails', '~> 1.0.0'
```
## Usage

```erb
<%= form_for(@order) do |f| %>
  <div class="field">
    <%= f.label :country_code %><br />
    <%= f.country_select :country_code, {priority: %w(US CA), prompt: 'Please select a country'} %>
  </div>
<% end %>
```

#### SimpleForm
Pass the object to the country_select helper. This ensures the persisted country is selected when the form is rendered. 

```erb
<%= simple_form_for @user do |f| %>
  <%= f.input :country_code do %>
    <%= f.country_select :country_code, {object: f.object, prompt: 'Country'} %>
  <% end %>
<% end %>
```

Passing the object is necessary when using nested form fields with Formtastic.

## How do I only display a subset of countries/regions?

Carmen had a concept of excluded countries in the old days, where you could
specify certain countries or regions to not include in a select.

The new (and much more flexible) way to handle this is to write a helper method
that returns the subset of regions you want to provide:

``` ruby
def only_us_and_canada
  Carmen::Country.all.select{|c| %w{US CA}.include?(c.code)}
end
```

And then in your form something like this:

``` erb
<%= f.select :country, region_options_for_select(only_us_and_canada) %>
```

More docs coming soon. In the meantime, all of the public methods in
carmen-rails [have been thoroughly TomDoc'ed](https://github.com/jim/carmen-rails/blob/master/lib/carmen/rails/action_view/form_helper.rb).

### Demo app

There is a [live demo app](http://carmen-rails-demo.herokuapp.com) that shows
carmen-rails in action, and includes a [step-by-step setup guide](https://github.com/jim/carmen-demo-app#readme).

## Configuration

Using this library will automatically set Carmen to use [Rails' built-in I18n functionality](http://guides.rubyonrails.org/i18n.html). This means that changing
some configuration should be done through Rails and not Carmen. For example, adding paths for additional locale files
should be done inside `config/application.rb`:

``` ruby
config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
```
