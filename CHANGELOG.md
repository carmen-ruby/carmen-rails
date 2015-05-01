### 1.0.2

* Rails 4.2 compatibility.

### 1.0.1

* Rails 4 compatibility.

### 1.0.0

Updates

* Push from beta to 1.0.0 final.  

### 1.0.0.beta 3

Bug Fixes

* Removed some 1.9 syntax taht prevented the gem from running on Ruby 1.8

Enhancements

* Region select options are now sorted (lukast-akra)

API Changes

* region_options_for_select now takes priority region codes in an options hash
  under the key 'priority'.
* The API for region_options_for_select now expects a collection of Carmen::Regions
  as its second argument instead of a parent region. This makes it simple to provide
  a custom collection of regions to build a select from.
