# TODOs

* use named tables, so that i do not have to update the order in which i return the data
  * so instead of { "foo", "bar" }
  * i would do { "data1": "foo", "data2": "bar" } (json)
  * in lua something like
    * local foo = { bar = "baz" }
    * foo["bar"]
* use the parameter (function is already implemented) in the fuzzy output
