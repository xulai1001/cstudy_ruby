#!/usr/bin/ruby
# -*- encoding: utf-8 -*-
$: << "ext/"

require "RHUtils"
include RHUtils

$pages_per_row = 32

# -- 1. allocate memory
mb = (ARGV[0] || 2048).to_i
puts "- allocate #{mb} MB memory..."
pages = allocate_mb(mb).group_by {|pg| IVY_BRIDGE.parse(pg.p).row}

# -- 2. release unused rows
puts "- release rows that we don't hold (<32 pages)"
pages.keys.select {|k| pages[k].size != $pages_per_row}.each {|k|
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
    # test once each 8kB
    pages[r-1].select {|p| (p.p >> PAGE_SHIFT).even? }.each {|p|
        # -- change row address of p to (r+1), with dram mapping semantics
        q = IVY_BRIDGE.change_row(p.p, r+1)
        qv = p2v(pages[r+1], q)
        # -- double check if there is really row conflict
        if qv and conflict?(p.v, qv)
            pages[r].each &:fill      # fill row with 0xff (c-routine)
            hammer(p.v, qv, 1024000) # hammer (c-routine)
            result = pages[r].select{|pg| pg.check != -1} # check (c-routine)
            if result.empty?
                STDOUT.write "."
            else
                puts
                STDOUT.write "%x - %x: %s" % [p.p, q, 
                    result.map {|pg| "%x+%x -> %x" % [pg.p, pg.check, pg[pg.check]]
                               }.join(" ") ]            
            end
        else
            STDOUT.write "x"
        end
    }
    puts
}
rescue Interrupt
puts "", "Interrupt"
end

# -- 5. cleanup
puts "cleanup..."
pages.values.flatten.each &:release

