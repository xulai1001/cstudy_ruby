require "./RHUtils"

ivy = RHUtils::IVY_BRIDGE

p = RHUtils::Page.new.acquire
pm = ivy.parse(p.p)

puts ivy, pm
puts "----"
puts ivy.parse(ivy.change_row(p.p, pm.row+2))
