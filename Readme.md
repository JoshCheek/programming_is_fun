Parsing HTTP requests
=====================

Getting Bootstrapped
--------------------

* Install rspec and mrspec `gem install mrspec rspec`
* Run the tests `$ mrspec`, they should blow up because:
  - [ ] you need to make a file
  - [ ] then because you need to make the class they're trying to test
  - [ ] then because you need to make a method (note what object the method is being called on -- the class, not the instance)
  - [ ] And then because it's receiving the wrong number of arguments
  - [ ] And then because it's returning nil instead of a hash
* Pay attention to what you are returning,
  if the last line is ever anything other than the hash,
  you are returning the wrong thing.

Restrictions
------------

You may only use these methods:


```ruby
# Strings: chomp, split, to_i, upcase, gsub, ==, !=, <<
"abc\n".chomp           # => "abc"
"aXbXc".split("X")      # => ["a", "b", "c"]
"123".to_i              # => 123
"HELLO world".upcase    # => "HELLO WORLD"
"aXbXc".gsub("X", " ")  # => "a b c"
"a" == "a"              # => true
"a" != "a"              # => false
string = "a"
string << "b"           # => "ab"
string                  # => "ab"

# Hash: []=, [], each
hash = {'a' => 'b'}        # => {"a"=>"b"}
hash['c'] = 'd'            # => "d"
hash['c']                  # => "d"
hash.each do |key, value|
  key                      # => "a", "c"
  value                    # => "b", "d"
end

# IO: gets, read(num_chars)
read_io, write_io = IO.pipe
write_io.puts "abc\ndef\nghi\njkl"

read_io.gets     # => "abc\n"
read_io.gets     # => "def\n"
read_io.read(5)  # => "ghi\nj"

read_io.close
write_io.close

# StringIO: .new
require 'stringio'
io = StringIO.new("abc\ndef\nghi\njkl")
io.read # => "abc\ndef\nghi\njkl"

# Array: each, []
array = ['a', 'b', 'c']

array.each do |char|
  char  # => "a", "b", "c"
end

array[0] # => "a"

# Any object: loop, to_s
loop do
  1  # => 1
  break if "a" == "a"
end

1.to_s  # => "1"
```


Use this approach for Zen
-------------------------

* Declare the hash at the top of the method, return it at the bottom, everything you do will be between these two (or you change the return value)
* Hard code the result you expect will make the test pass, then see that it passes (to verify you're about to do the right work)
* Replace the value of the hash with a local variable that has the same value (not the key, the key is hard-coded)
* Place a pry between within the method (not the last line or you change the return value)
  and look at the local variables available to you...
* What methods can you call on those objects? Try calling them, what do you get back?
  What methods can you call on those? Try calling them?
* Think about the names of the variables and of the methods, what do those names mean?
* What things are in the hash? Do you need any of them for other stuff? Can you make any hypotheses about why they are named that?


Putting them together
---------------------

If you complete the two test suites above, and want to do the last bit,
ping me and I'll add the test for it (you're probably 60% done at this point).
