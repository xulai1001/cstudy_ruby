#!/usr/bin/ruby
# -*- encoding: utf-8 -*-
$: << "ext/"

require "RHUtils"
require "pp"
require "json"
include RHUtils

# obf latency routine
def genseed(*bits)
    $seed.map {|s|
        pa = $base + s
        pb = $base + bit_flip(s, *bits)
        va = p2v($pages, pa)
        vb = p2v($pages, pb)
        [va, vb]
    }
end

def latency(*bits)
    genseed(*bits).count {|x| conflict?(*x) }
end

def access(*bits)
    genseed(*bits).map {|x| access_time(*x) }
end

# -- 1. allocate memory
mb = (ARGV[0] || 2048).to_i
$pages = allocate_cap(mb)
$base = $pages[0].p
order = 63-bit_clz($pages.size)+12
puts "we can control the least #{order} bits of phys-addr"

# -- 2. generate very small seed (6) for quick measure
srand
$seed = Array.new(5) {rand(1 << order)}

# -- 3. measure latency
begin
$latency_map = {}
$access_map = {}
(1..2).each {|m|
    (3...order).to_a.combination(m).each {|bits|
        $access_map[bits] = access(*bits)
        $latency_map[bits] = $access_map[bits].count {|x| x >= RHUtils.threshold}
        puts "#{bits} => #{$access_map[bits]} => #{$latency_map[bits]}"
    }
}

puts "---------------"
# -- 4. generate large seed (100) for precise measure
$seed = Array.new(100) {rand(1 << order)}
$latency_map.keys.select {|k| $latency_map[k] > 0 }.each {|k|
    $latency_map[k] = latency(*k)
    puts "#{k} => #{$latency_map[k]}"    
}
   

rescue Interrupt
    puts "Interrupted"
end

File.open("result_measure.txt", "w") {|f| f.puts JSON.dump($latency_map)}

# -- 4. cleanup
puts "cleanup..."
$pages.each &:release
