require "./RHUtils"

puts "acquiring memory..."
pages = RHUtils.allocate_mb ARGV[0].to_i || 2048
puts "acquired #{pages.size} pages #{pages.size/256} MB"
range = RHUtils.find_contiguous_aligned_range(pages)
puts "#{range.size} pages, #{range.size/256} MB, address #{'%x' % pages[range.begin].p} -> #{'%x' % (pages[range.end].p-1)}"
(pages - pages[range]).tap{|pg| pg.each &:release; puts "#{pg.size} unused pages released"}
pages[range].each &:release
puts "#{range.size} pages released"
