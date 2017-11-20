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
    genseed(*bits).map {|x| [x[0], x[1], access_time(*x)] }
end

# -- 1. allocate memory
mb = (ARGV[0] || 2048).to_i
$pages = allocate_cap(mb)
$base = $pages[0].p
order = 63-bit_clz($pages.size)+12
puts "we can control the least #{order} bits of phys-addr"

# -- 2. generate small seed (10) for quick measure
srand
$seed = Array.new(10) {rand(1 << order)}

# -- 3. measure latency
begin
$latency_map = {}
(1..3).each {|m|
    (3...order).to_a.combination(m).each {|bits|
        $latency_map[bits] = latency(*bits) * 10
        puts "#{bits} => #{$latency_map[bits]}"
    }
}

puts "---------------"
# -- 4. generate large seed (100) for precise measure
$seed = Array.new(100) {rand(1 << order)}
$latency_map.keys.select {|k| $latency_map[k].between?(10, 90) }.each {|k|
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
