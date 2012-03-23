# carmen-rails

carmen-rails is a Rails 3 plugin that supplies two new form helper methods:
`country_select` and `subregion_select`. It uses
[carmen](http://github.com/jim/carmen) as its source of geographic data.

## Installation

Just add carmen-rails to your Gemfile:

```ruby
gem 'carmen-rails', '1.0.0.pre'
```

## Usage

```erb
<%= form_for(@order) do |f| %>
  <div class="field">
    <%= f.label :country_code %><br />
    <%= f.country_select :country_code, priority: %w(US CA), prompt: 'Please select a country' %>
  </div>
<% end %>
```

More docs coming soon.

### Demo app

There is a [live demo app](http://carmen-rails-demo.herokuapp.com) that shows
carmen-rails in action.
