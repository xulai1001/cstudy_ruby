# -*- encoding: utf-8 -*-
# DRAM mapping code

# add get bit range
class Fixnum
    alias :get_bit :[]
    def [](x)
        if x.is_a?(Range)
            (self >> x.begin) & ((1 << (x.end-x.begin+1)) - 1)
        else
            get_bit(x)
        end
    end
end

module RHUtils

    # merge several given bits, from low to high
    # e.g. bit_merge([[0b110, 3], [0b1000, 4], [0b1010, 4]]) = 1010 1000 110
    # corrsponding left shift bits are [0, 3, 7]
    def bit_merge(bits)
        ret = 0; sh = 0
        bits.each {|b|
            ret |= (b[0] << sh)
            sh += b[1]
        }
        ret
    end
    
    # bit_merge(x, [0..3, 5..7]) = x[7,6,5,3,2,1,0]
    def bit_merge_range(x, ranges)
        bit_merge(ranges.map{|r| [x[r], r.size]})
    end
    
    # select [bits] bits in x and xor them
    def bit_xor(x, bits)
        bits.map{|b| x[b]}.reduce(:^)
    end
    
    class DramAddr
        attr_accessor :p, :row, :bank, :bg, :rank, :channel
        
        def initialize(&block)
            instance_eval &block
        end
        
        def to_s
            "DramAddr: 0x%x row: %016b bank: %03b bg: %02b rank: %b channel: %b" % 
            [@p, @row, @bank, @bg, @rank, @channel]
        end
    end
    
    class DramMapping
        attr_accessor :name, :row_ranges, :bank_bits, :bg_bits
        attr_accessor :chnl_bits, :rank_bits
        
        def initialize(&block)
            instance_eval &block
        end
        
        # given phys addr, parse it into DramAddr
        def parse(paddr)
            DramAddr.new {
                p       = paddr
                row     = bit_merge_range(paddr, row_ranges)
                bank    = bit_merge(bank_bits.map{|b| [bit_xor(paddr, b), 1]})
                bg      = bit_merge(bg_bits.map  {|b| [bit_xor(paddr, b), 1]})
                rank    = bit_xor(paddr, range_bits)
                channel = bit_xor(paddr, chnl_bits)
            }
        end
        
        # change the row address of p to r, assuming single xor-scheme
        # currently do not consider channels!!!
        def change_row(p, r)
            
        end
    end
    
end
