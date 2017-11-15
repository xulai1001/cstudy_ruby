# -*- encoding: utf-8 -*-
# ruby wrapping of RHUtils C module
require "./RHUtils.so"

module RHUtils
    
    # row conflict threshold (ticks)
    @threshold = 250
    
    class Page
        def [](offset)
            get(offset)
        end
    end
    
    module_function
    
    def conflict?(a, b)
        access_time(a, b) > @threshold
    end
end
