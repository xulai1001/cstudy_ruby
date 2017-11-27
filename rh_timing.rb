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

class HammerInfo < Struct.new("HammerInfo", :p, :page, :value, :n, :ticks, :pairs)
    def inspect
        "#<HammerInfo p=0x%x value=%x n=#{self.n} ticks=#{self.ticks}>" % [self.p, self.value]
    end
end

$pages_per_row = 32
$result = {}
$ntime_max = 1024000

def update_result(r, ntime, ticks, pair)
    flag = false
    $pages[r].each {|pg|
        pg.check.each {|i|
            pa = pg.p+i
            info = $result[r][pa] || HammerInfo.new(
                p = pa,
                page = pg,
                value = pg[i],
                n = ntime,
                ticks = ticks,
                pairs = []
            )                           
            info.pairs << pair; info.pairs.uniq!  # hammer page object
            if ntime < info.n
                info.n, info.ticks = ntime, ticks
                flag = true
            end
            $result[r][pa] = info
        }            
    }
    return flag
end

# first scan row with max ntime
def test_row_first(r)
    $result[r] ||= {}
    ntime = $ntime_max
    
    # -- select first hammer addr: every 8kB
    $pages[r-1].select{|p| (p.p >> PAGE_SHIFT).even? }.each {|p|
        # -- select second hammer addr: every 8kB, only with row conflict
        $pages[r+1].select {|q|
            (q.p >> PAGE_SHIFT).even? and conflict?(p.v, q.v)
        }.each {|q|
            $pages[r].each &:fill       # fill row with 0xff (c-routine)
            ticks = hammer(p.v, q.v, ntime) # hammer (c-routine) virt addrs
            update_result(r, $ntime_max, ticks, [p, q])
        }
    }
end

# second shrink hammer time and test again
def test_hammer_time(r)
    flag = true
    ntime = $ntime_max - 100000
    pair = $result[r].values[0].pairs[0] # just pick one pair ????
    
    while (ntime > 0 and flag)
        puts ntime
        $pages[r].each &:fill
        ticks = hammer(pair[0].v, pair[1].v, ntime)
        flag = update_result(r, ntime, ticks, pair)
        ntime -= 100000
    end
end

# -- 1. allocate memory
mb = (ARGV[0] || 2048).to_i
puts "- allocate #{mb} MB memory..."
$pages = allocate_mb(mb).group_by(&:row)

# -- 2. release unused rows
puts "- release rows that we don't hold (<32 pages)"
$pages.keys.select {|k| $pages[k].size < $pages_per_row}.each {|k|
    $pages[k].each &:release
    $pages.delete(k)
}
# -- 3. select test rows
test_rows = $pages.keys.select {|k| $pages.has_key?(k-1) and $pages.has_key?(k+1)}

# -- 4. start testing
begin
puts "- start testing"
test_rows.each {|r|
    puts "- Row ##{r}"
    test_row_first(r)
    test_hammer_time(r) if !$result[r].empty?
    puts $result
    puts "--------------------------------------"
}
rescue Interrupt
puts "", "Interrupt"
end

# -- 5. cleanup
puts "cleanup..."
$pages.values.flatten.each &:release

