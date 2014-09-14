Geohash
=======

Geohash en/decode library written in Ruby.


Install
-------

```ruby
gem 'geohash_ruby'
```


Usage
-----

### Encode latitude and longitude into geohash

```ruby
Geohash.encode 47.6062095, -122.3320708
#=> "c23nb62w20st"

Geohash.encode 47.6062095, -122.3320708, 6
#=> "c23nb6"
```

### Decode from geohash

```ruby
Geohash.decode 'c23nb6'
#=> [[47.603759765625, -122.332763671875], [47.6092529296875, -122.32177734375]]
```

### Adjacent

```ruby
Geohash.adjacent 'c23nb6', :top
#=> "c23nb7"
```

### Neighbors

```ruby
Geohash.neighbors 'xn774c'
#=> ["xn774f", "xn7754", "xn7751", "xn7750", "xn774b", "xn7748", "xn7749", "xn774d"]

=begin
+--------+--------+--------+
| xn774d | xn774f | xn7754 |
+--------+--------+--------+
| xn7749 | xn774c | xn7751 |
+--------+--------+--------+
| xn7748 | xn774b | xn7750 |
+--------+--------+--------+
=end
```

### Walk

```ruby
Geohash.walk 'xn774c', [
  :top,
  :right,
  :bottom, :bottom,
  :left, :left,
  :top, :top
]
#=> ["xn774f", "xn7754", "xn7751", "xn7750", "xn774b", "xn7748", "xn7749", "xn774d"]
# implementation of `neighbors`
```


License
-------

This project is copyright by [Creasty](http://www.creasty.com), released under the MIT lisence.  
See `LICENSE` file for details.
