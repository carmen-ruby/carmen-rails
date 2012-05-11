### HEAD

Bug Fixes

* Removed some 1.9 syntax taht prevented the gem from running on Ruby 1.8
*
Enhancements

* Region select options are now sorted (lukast-akra)

API Changes

* region_options_for_select now takes priority region codes in an options hash
  under the key 'priority'.
