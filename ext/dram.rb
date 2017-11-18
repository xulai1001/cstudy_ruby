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
    module_function
    
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
    
    # split x into bit slices, from low to high
    # e.g. bit_split(0b1010 1000 110, [3, 4, 4]) = [0b110, 0b1000, 0b1010]
    def bit_split(x, lens)
        ret = []
        lens.each {|l|
            ret << (x & ((1 << l)-1))
            x >>= l
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
    
    class DramAddr < Struct.new("DramAddr", :p, :row, :bank, :bg, :rank, :channel)
        def to_s
            "DramAddr: 0x%x %32b, row: %016b bank: %03b bg: %02b rank: %b channel: %b" % 
            [p, p, row, bank, bg || 0, rank, channel || 0]
        end
    end
    
    class DramMapping < Struct.new("DramMapping", 
        :name, :row_ranges, :bank_bits, :bg_bits, :chnl_bits, :rank_bits)
        
        # given phys addr, parse it into DramAddr
        def parse(paddr)
            DramAddr.new(
                p = paddr,
                row = RHUtils.bit_merge_range(paddr, row_ranges),
                bank = RHUtils.bit_merge(bank_bits.map{|b| [RHUtils.bit_xor(paddr, b), 1]}),
                bg = RHUtils.bit_merge(bg_bits.map  {|b| [RHUtils.bit_xor(paddr, b), 1]}),
                rank = RHUtils.bit_xor(paddr, rank_bits),
                channel = RHUtils.bit_xor(paddr, chnl_bits)
            )
        end
        
        # change the row address of p to r while keeping bank/rank address
        # assuming single xor-scheme. currently do not consider channels!!!
        def change_row(p, r)
            # 1. change row addr of p to r
            clear_mask = 0; set_mask = 0
            r_bits = RHUtils.bit_split(r, row_ranges.map{|rr| rr.size})
            r_bits.each_index{|i|
                clear_mask |= ((1 << row_ranges[i].size)-1) << row_ranges[i].begin
                set_mask |= r_bits[i] << row_ranges[i].begin
            }
            q = (p & ~clear_mask) | set_mask
            
            # 2. count new bank/rank address
            # for each b/r bit, bit_xor(p, bits) should = bit_xor(q, bits)
            # if not so, we should flip the non-row bit (b/r_bit) in q[bits]
            # the b/r bit can be extracted by minusing bit sets (bits-row_bit_arr)
            # e.g. [13, 17] - [17..18, 22..31] = [13]
            row_bit_arr = row_ranges.map(&:to_a).flatten
            (bank_bits + [rank_bits]).each {|bits|
                if RHUtils.bit_xor(p, bits) != RHUtils.bit_xor(q, bits) 
                    q = RHUtils.bit_flip(q, *(bits - row_bit_arr))
                end                    
            }
            # return the new address (q)
            q
        end
    end
    
    IVY_BRIDGE = DramMapping.new(
        name = "IvyBridge",
        row_ranges = [17..31],
        bank_bits = [[13, 17], [14, 18], [15, 19]],
        bg_bits = [],
        chnl_bits = [],
        rank_bits = [16, 20]
    )
    
end
