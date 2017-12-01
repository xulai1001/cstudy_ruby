#!/usr/bin/ruby
# -*- encoding: utf-8 -*-
$: << "ext/"

require "RHUtils"
require "pp"
require "json"

$filename = ARGV[0] || "result_measure.txt"
$latency = {}

JSON.load(File.read($filename)).each{|k, v| $latency[eval(k)] = v}

# pp $measure

def conflict?(*args)
    $latency[args.sort] >= 90 rescue false
end

def partial?(*args)
    $latency[args.sort].between?(20, 90) rescue false
end

$max_bit = $latency.keys.flatten.max
$bits = 3..$max_bit

# 1. pure row bits: 100% conflict with only 1 bit flip
$row_bits = $bits.select {|x| conflict?(x) }
$low_bits = (3...$row_bits.min).to_a
$row_partial = $bits.select {|x| partial?(x) }

p $row_bits, $low_bits, $row_partial
