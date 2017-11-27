#!/usr/bin/ruby
# -*- encoding: utf-8 -*-
$: << "../ext/"

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

$pages_per_row = 32

# -- 1. allocate memory
mb = (ARGV[0] || 2048).to_i
puts "- allocate #{mb} MB memory..."
pages = allocate_mb(mb).group_by(&:row)

# -- 2. release unused rows
puts "- release rows that we don't hold (<32 pages)"
pages.keys.select {|k| pages[k].size < $pages_per_row}.each {|k|
    pages[k].each &:release
    pages.delete(k)
}
# -- 3. select test rows
test_rows = pages.keys.select {|k| pages.has_key?(k-1) and pages.has_key?(k+1)}

# -- 4. start testing
begin
puts "- start testing"
test_rows.each {|r|
    STDOUT.write "- Row ##{r}:"
    # -- my change: test every 8kB
    pages[r-1].select{|p| (p.p >> PAGE_SHIFT).even? }.each {|p|
        # -- my change: only test if there is row conflict
        pages[r+1].select {|q|
            (q.p >> PAGE_SHIFT).even? and conflict?(p.v, q.v)
        }.each {|q|
            pages[r].each &:fill      # fill row with 0xff (c-routine)
            hammer(p.v, q.v, 1024000) # hammer (c-routine)
            result = pages[r].select{|pg| !pg.check.empty?} # check (c-routine)
            if result.empty?
                STDOUT.write "."
            else
                puts
                STDOUT.write "%x - %x: %s" % [p.p, q.p, 
                    result.map {|pg| "%x+%s -> %x" % [pg.p, pg.check.to_s, pg[pg.check[0]]]
                               }.join(" ") ]            
            end
        }
    }
    puts
}
rescue Interrupt
puts "", "Interrupt"
end

# -- 5. cleanup
puts "cleanup..."
pages.values.flatten.each &:release

