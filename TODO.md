# TODOs

* use named tables, so that i do not have to update the order in which i return the data
  * so instead of { "foo", "bar" }
  * i would do { "data1": "foo", "data2": "bar" } (json)
  * in lua something like
    * local foo = { bar = "baz" }
    * foo["bar"]
* ~~parse the content of the file or the range and let the fuzzy finder display it as a preview~~
* use the parameter (function is already implemented) in the fuzzy output
* add testing part
  * put files, check if result is correct (without fuzzy finder ofc)
* create new gif
  * show fzf and telescope
  * use this project and maybe js as an example (update js namings)
