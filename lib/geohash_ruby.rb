module Geohash

  VERSION = '1.0.2'

  BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz'

  NEIGHBORS = {
    right: [
      'bc01fg45238967deuvhjyznpkmstqrwx',
      'p0r21436x8zb9dcf5h7kjnmqesgutwvy',
    ],
    left: [
      '238967debc01fg45kmstqrwxuvhjyznp',
      '14365h7k9dcfesgujnmqp0r2twvyx8zb',
    ],
    top: [
      'p0r21436x8zb9dcf5h7kjnmqesgutwvy',
      'bc01fg45238967deuvhjyznpkmstqrwx',
    ],
    bottom: [
      '14365h7k9dcfesgujnmqp0r2twvyx8zb',
      '238967debc01fg45kmstqrwxuvhjyznp',
    ]
  }

  BORDERS = {
    right:  ['bcfguvyz', 'prxz'],
    left:   ['0145hjnp', '028b'],
    top:    ['prxz', 'bcfguvyz'],
    bottom: ['028b', '0145hjnp'],
  }

  @@neighbors_cache = {}

  @@adjacent_cache = {
    right: {}, left: {}, top: {}, bottom: {}
  }


module_function

  ###
  # Decode geohash into bounding box of latitudes and longitudes
  #
  # @params {String} geohash - geohash code
  #
  # @return {[[Float]]} decoded bounding box
  #   [
  #     [north_latitude, west_longitude],
  #     [south_latitude, east_longitude]
  #   ]
  ###
  def decode(geohash)
    bounds = [[-90.0, +90.0], [-180.0, +180.0]]

    geohash.downcase.each_char.with_index do |c, i|
      d = BASE32.index c

      5.times do |j|
        bit = (d & (1 << (4 - j))) >> (4 - j)
        k = (~i & 1) ^ (j & 1)
        bounds[k][bit ^ 1] = (bounds[k][0] + bounds[k][1]) / 2
      end
    end

    bounds.transpose
  end

  ###
  # Encode latitude and longitude into geohash
  #
  # @params {Float} latitude
  # @params {Float} longitude
  # @params {Integer} precision - scale from 1 to 12
  #
  # @return {String} geohash string
  ###
  def encode(latitude, longitude, precision = 12)
    mids = [latitude, longitude]
    bounds = [[-90.0, +90.0], [-180.0, +180.0]]

    geohash = ''

    precision.times do |i|
      d = 0

      5.times do |j|
        k = (~i & 1) ^ (j & 1)
        mid = (bounds[k][0] + bounds[k][1]) / 2
        bit = mids[k] > mid ? 1 : 0
        bounds[k][bit ^ 1] = mid
        d |= bit << (4 - j)
      end

      geohash << BASE32[d]
    end

    geohash
  end

  ###
  # Encode binary string into geohash
  #
  # @params {String} binary_string
  #
  # @return {[[Float]]} decoded bounding box
  #   [
  #     [north_latitude, west_longitude],
  #     [south_latitude, east_longitude]
  #   ]
  ###
  def decode_binary(binary_string)
    decode(encode_binary(binary_string))
  end

  ###
  # Encode latitude and longitude into geohash
  #
  # @params {String} binary_string
  #
  # @return {String} geohash string
  #
  def encode_binary(binary_string)
    geohash = ''

    binary_string.scan(/.{1,5}/).each do |bit_part|
      d = 0
      bit_part.each_char.with_index do |c, i|
        d |= c.to_i << (4 - i)
      end

      geohash << BASE32[d]
    end

    geohash
  end

  ###
  # Calculate neighbors geohash
  #
  # @params {String} geohash
  #
  # @return {[String]} neighbors array
  ###
  def neighbors(geohash)
    return @@neighbors_cache[geohash] if @@neighbors_cache[geohash]

    # walk path:
    #
    # 8   1 - 2
    # |   |   |
    # 7   B   3
    # |       |
    # 6 - 5 - 4
    #
    @@neighbors_cache[geohash] = walk geohash, [
      :top,
      :right,
      :bottom, :bottom,
      :left, :left,
      :top, :top
    ]
  end

  ###
  # Calculate adjacent geohashes
  #
  # @params {String} geohash
  # @params {Symbol} dir - one of :right, :left, :top, :bottom
  #
  # @return {String} adjacent geohash
  ###
  def adjacent(geohash, dir)
    return @@adjacent_cache[dir][geohash] if @@adjacent_cache[dir][geohash]

    head, last = geohash[0..-2], geohash[-1]
    parity = geohash.length & 1

    head = adjacent(head, dir) if BORDERS[dir][parity].include?(last) && head.length > 0

    # NOTICE: do not use append `<<` instead of `+=`
    head += BASE32[NEIGHBORS[dir][parity].index(last)]

    @@adjacent_cache[dir][geohash] = head
  end

  ###
  # Walk down
  #
  # @params {String} base - base geohash to begin walk
  # @params {[Symbol]} path - directions to walk with
  #
  # @return {[String]} result geohashes of the walk
  ###
  def walk(base, path)
    path.map { |dir| base = adjacent(base, dir) }
  end

end
