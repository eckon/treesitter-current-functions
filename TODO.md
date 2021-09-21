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
* add other fuzzy finder integration
 * add general approach that checks what the user has and use that so that it does not need to be done manually
 * make approach easier for others to integrate their own stuff
* remove fzf from the main vim file
  * similar to lua have a selector folder for these
