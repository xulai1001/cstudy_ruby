# -*- encoding: utf-8 -*-
# ruby wrapping of RHUtils C module
require "./RHUtils.so"
require "./dram"

module RHUtils
    
    PAGE_SIZE = 4096
    PAGE_SHIFT = 12
    
    # row conflict threshold (ticks)
    @threshold = 250
    
    class Page
        def [](offset)
            get(offset)
        end
        
        def []=(offset, x)
            set(offset, x)
        end
        
        def <=>(pg)
            self.p <=> pg.p
        end
    end
    
    module_function
    
    def conflict?(a, b)
        access_time(a, b) > @threshold
    end
    
    def allocate_mb(mb, cls=Page)
        ret = Array.new(256*mb) {cls.new} # 256 pages/MB
        ret.each &:acquire
        ret.sort!
        ret
    end
    
    # gcap routine
    def get_contiguous_aligned_page(arr)
        chunk_length = []
        max_len = max_idx = 0
        arr.each_index {|i|
            if i>0 and arr[i].p-arr[i-1].p==PAGE_SIZE
                chunk_length[i] = chunk_length[i-1]+1
            else
                chunk_length[i] = 1
            end
            if chunk_length[i] > max_len
                max_len = chunk_length[i]
                max_idx = i
            end
        }
        start_idx = max_idx-max_len+1
        ret_order = 64 - bit_clz(max_len)  # number of returning pages is (1<<ret_order)
        ret_start = nil
       # puts "max_len = #{max_len}, max_range #{max_idx-max_len+1..max_idx}"
        while !ret_start and ret_order > 0
            ret_order -= 1
            ret_start = (start_idx..(max_idx-(1 << ret_order))).find {|x|
                # e.g. if ret_order=4 (return & align to 16 pages)
                # then physical address (pa) should have 4+12 bit 0-s
                # the least 1-bit (ffs) of pa should be 4+12+1=17
                bit_ffs(arr[x].p) >= ret_order + PAGE_SHIFT + 1
            }
        end
        
        return ret_start...(ret_start + (1 << ret_order))
    end
    
    # allocate_mb + gcap. free unused pages. return available slice
    def allocate_cap(mb, cls=Page)
        puts "acquiring memory..."
        pages = allocate_mb(mb, cls)
        puts "acquired #{pages.size} pages #{mb} MB"
        
        range = get_contiguous_aligned_page(pages)
        puts "CAP is %d pages %d MB, address %x -> %x" % 
            [range.size, range.size/256, pages[range.begin].p, pages[range.end].p-1]
        
        (pages - pages[range]).tap{|unused|
            unused.each &:release
            puts "#{unused.size} unused pages released"
        }
        return pages[range]        
    end
    
    # in given pages collection, find corresponding vaddr
    def p2v(pages, p)
        offset = p % PAGE_SIZE
        base = p - offset
        pg = pages.find {|x| x.p == base}
        return pg ? pg.v+offset : nil
    end
    
    # flip args bits in x
    def bit_flip(x, *args)
        mask = args.reduce(0) {|ret, arg| ret | (1 << arg)}
        return x ^ mask
    end
end

# todo: unit test
