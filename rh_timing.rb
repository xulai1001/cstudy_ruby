#!/usr/bin/ruby
# -*- encoding: utf-8 -*-
$: << "ext/"

require "RHUtils"
module RHUtils
    class Page
        
        ROW_SHIFT = 17
        def row
            @p >> ROW_SHIFT
        end
    end
end

include RHUtils

class HammerResult < Struct.new("HammerInfo", :p, :page, :value, :n, :ticks, :pairs)
    def inspect
        "#<HammerResult p=0x%x value=%x n=#{self.n} ticks=#{self.ticks} pairs=#{pairs}>" % [self.p, self.value]
    end
    
    def offset; self.p - self.page.p; end
    def ns; RHUtils.ticks_to_ns(self.ticks); end
    
    def explain
        addr = "pa 0x%x+%x value %x" % [self.page.p, self.offset, self.value]
        timing = "hammer %d times %d ms (avg %d ns)" % [self.n, self.ns/1000000, self.ns/self.n]
        pair = self.pairs.map {|x| "%x-%x" % [x[0].p, x[1].p]}.join(" ")
        return [addr, timing, pair].join(", ")        
    end 
end

$pages_per_row = 32
$result = {}

# test row [r] by hammering [ppage, qpage] (on row (r-1, r+1) and with row conflict)
# and update result hash
def hammer_row(r, ppage, qpage, ntime)
    flag = false
    $result[r] ||= {}
        
    # fill row with 0xff (c-routine)
    $pages[r-1].each {|pg| pg.fill(0x55)}
    $pages[r].each {|pg| pg.fill(0xaa)}
    $pages[r+1].each {|pg| pg.fill(0x55)}
    
    # hammer virt addrs (c-routine)
    ticks = hammer(ppage.v, qpage.v, ntime, $lat)

    # parse result
    $pages[r].each {|pg|
        # with each bug offset i, update result hash
        pg.check(0xaa).each {|i|
            pa = pg.p+i
            info = $result[r][pa] || HammerResult.new(
                p = pa,
                page = pg,
                value = pg[i],
                n = ntime,
                ticks = ticks,
                pairs = []
            )                           
            info.pairs << [ppage, qpage]; info.pairs.uniq!  # hammer page object
            if ntime <= info.n
                info.n, info.ticks = ntime, ticks
                flag = true
            end
            $result[r][pa] = info
        }            
    }
    return flag
end

# select hammer pages:
# p: on row (r-1), every 8kB
# q: on row (r+1), every 8kB, row conflict with p
# hammer them with $ntime_max times to get initial result
def test_row_first(r)
    flag = false
    $pages[r-1].select{|p| (p.p >> PAGE_SHIFT).even? }.each {|p|
        $pages[r+1].select {|q| (q.p >> PAGE_SHIFT).even? and conflict?(p.v, q.v)
        }.each {|q|
            flag |= hammer_row(r, p, q, $ntime_max)
        }  
    }
    return flag
end

# test smallest loop time to invoke bit flip
def test_hammer_time(r)
    flag = true
    ntime = $ntime_max - 100000
    pair = $result[r].values[0].pairs[0] # just pick one pair ????
    
    while (ntime > 0 and flag)
        # puts ntime
        hammer_row(r, pair[0], pair[1], ntime)
        ntime -= 100000
    end
end

# -- 1. allocate memory
mb = 2048
$lat = (ARGV[0] || 0).to_i
$ntime_max = (ARGV[1] || 1024000).to_i
$start_row = (ARGV[2] || 0).to_i

puts "- allocate #{mb} MB memory..."
$pages = allocate_mb(mb).group_by(&:row)

# -- 2. release unused rows
puts "- release rows that we don't hold (<32 pages)"
$pages.keys.select {|k| $pages[k].size < $pages_per_row}.each {|k|
    $pages[k].each &:release
    $pages.delete(k)
}
# -- 3. select test rows
test_rows = $pages.keys.select {|k| $pages.has_key?(k-1) and $pages.has_key?(k+1) and k>=$start_row}

# -- 4. start testing
begin
puts "- start testing"
test_rows.each {|r|
    puts "- Row #{r} -"
    if test_row_first(r)
        # if found bug, test min time to invoke it
        test_hammer_time(r)
        $result[r].each_value {|v|
            puts v.explain
            puts "-----------"
        }
    end
}
rescue Interrupt
puts "", "Interrupt"
end

# -- 5. cleanup
puts "cleanup..."
$pages.values.flatten.each &:release

