#include "ruby.h"
#include "unistd.h"
#include "errno.h"
#include "stdint.h"
#include "fcntl.h"
#include "sys/mman.h"
#include "time.h"
#include "stdio.h"
#include "linux/types.h"
#include "sys/stat.h"
#include "sys/sysinfo.h"

#include "timing.h"
#include "hammer.h"

//page select
#define PAGE_SIZE 0x1000
#define PAGE_MASK 0xfff
#define PAGE_SHIFT 12
#define PAGE_FLAG 0
#define HUGE_SIZE 0x200000ull
#define HUGE_MASK 0x1fffffull
#define HUGE_SHIFT 21
#define HUGE_FLAG 0x40000
#define PFN_MASK ((1ull << 55) - 1)

#define ALLOC_SIZE PAGE_SIZE
#define ALLOC_FLAG (MAP_PRIVATE | MAP_ANONYMOUS) // | HUGE_FLAG)

// v2p.h
#define ASSERT(line) if (!(line)) { rb_sys_fail("ASSERT error: " #line); }
int fd_pagemap = -1;

uint64_t v2p(void *v) {
    if (fd_pagemap < 0) ASSERT((fd_pagemap = open("/proc/self/pagemap", O_RDONLY)) > 0);
    uint64_t vir_page_idx = (uint64_t)v / PAGE_SIZE;      // 虚拟页号
    uint64_t page_offset = (uint64_t)v % PAGE_SIZE;       // 页内偏移
    uint64_t pfn_item_offset = vir_page_idx*sizeof(uint64_t);   // pagemap文件中对应虚拟页号的偏移
    
//    int dummy = *(int *)v;  // visit the addr, keep it in memory
    // 读取pfn
    uint64_t pfn_item, pfn;
    ASSERT( lseek(fd_pagemap, pfn_item_offset, SEEK_SET) != -1 );
    ASSERT( read(fd_pagemap, &pfn_item, sizeof(uint64_t)) == sizeof(uint64_t) );
    pfn = pfn_item & PFN_MASK;              // 取低55位为物理页号

    return pfn * PAGE_SIZE + page_offset;
}

// ruby bindings
static VALUE module;
static VALUE page_class;

static VALUE initialize(VALUE self)
{
    rb_iv_set(self, "@v", INT2FIX(0));  //actually int 1
    rb_iv_set(self, "@p", INT2FIX(0));
    
    return self;
}

// acquire a page
static VALUE acquire(VALUE self)
{
    void *v;
    int64_t p;
    ASSERT((v = (char *)mmap(0, ALLOC_SIZE, PROT_READ | PROT_WRITE, ALLOC_FLAG, -1, 0)) != MAP_FAILED);
    memset(v, 0, ALLOC_SIZE);
    p = v2p(v);
    
    rb_iv_set(self, "@v", ULL2NUM((uint64_t)v));
    rb_iv_set(self, "@p", ULL2NUM(p));
    return self;
}

static VALUE release(VALUE self)
{
    void *v = (void *)NUM2ULL(rb_iv_get(self, "@v"));
    if (v) munmap(v, ALLOC_SIZE);
    rb_iv_set(self, "@v", INT2FIX(0));  //actually int 1
    rb_iv_set(self, "@p", INT2FIX(0));
    return self;
}

// fill page with 0xff
static VALUE fill(VALUE self)
{
    void *v = (void *)NUM2ULL(rb_iv_get(self, "@v"));
    memset(v, 0xff, ALLOC_SIZE);
    return self;
}

// check hammer faults, returns **all offsets**
static VALUE check(VALUE self)
{
    uint8_t *v = (uint8_t *)NUM2ULL(rb_iv_get(self, "@v"));
    int i;
    VALUE ret = rb_ary_new();
    for (i=0; i<ALLOC_SIZE; ++i)
        if (v[i] != 0xff) rb_ary_push(ret, INT2FIX(i));
    return ret;
}

// get v[i]
static VALUE get(VALUE self, VALUE off)
{
    uint8_t *v = (uint8_t *)NUM2ULL(rb_iv_get(self, "@v"));
    int i = FIX2INT(off);
    return INT2FIX(v[i]);
}

// set byte v[i]
static VALUE set(VALUE self, VALUE off, VALUE x)
{
    uint8_t *v = (uint8_t *)NUM2ULL(rb_iv_get(self, "@v"));
    int i = FIX2INT(off);
    v[i] = (uint8_t)FIX2INT(x);
    return self;
}

static VALUE rb_hammer(VALUE self, VALUE a, VALUE b, VALUE n)
{
    void *va = (void *)NUM2ULL(a), *vb = (void *)NUM2ULL(b);
    int ntimes = FIX2INT(n);
    return ULL2NUM(hammer_loop(va, vb, ntimes));
}

static VALUE rb_access_time(VALUE self, VALUE a, VALUE b)
{
    void *va = (void *)NUM2ULL(a), *vb = (void *)NUM2ULL(b);
    int access_time = 999, t;
    while (access_time > 400)
    {
        t = hammer_loop(va, vb, 100) / (100*2);
        if (t<access_time) access_time = t;
    }
    return INT2FIX(access_time);
}

// get lowest 1-bit, e.g. ffs(10101000b) = 4
static VALUE bit_ffs(VALUE self, VALUE x)
{
    return INT2FIX(__builtin_ffsll(NUM2ULL(x)));
}

// get number of 0-s before highest 1-bit, e.g. clz(10101000b) = (32-8) = 24
static VALUE bit_clz(VALUE self, VALUE x)
{
    return INT2FIX(__builtin_clzll(NUM2ULL(x)));
}

static VALUE rb_mem_size(VALUE self)
{
    struct sysinfo info;
    sysinfo(&info);
    return ULL2NUM((size_t)info.totalram * (size_t)info.mem_unit);
}

static VALUE rb_get_cpu_freq(VALUE self)
{
    return ULL2NUM(tsc_measure_freq());
}

void Init_RHUtils()
{
    module = rb_define_module("RHUtils");   // module HammerUtils
    page_class = rb_define_class_under(module, "Page", rb_cObject);     // class Page
        rb_define_attr(page_class, "v", 1, 0);  // attr_reader :v
        rb_define_attr(page_class, "p", 1, 0);  // attr_reader :p
        rb_define_method(page_class, "initialize", initialize, 0);
        rb_define_method(page_class, "acquire", acquire, 0);
        rb_define_method(page_class, "release", release, 0);
        rb_define_method(page_class, "check", check, 0);
        rb_define_method(page_class, "fill", fill, 0);
        rb_define_method(page_class, "get", get, 1);
        rb_define_method(page_class, "set", set, 2);
    rb_define_module_function(module, "hammer", rb_hammer, 3);
    rb_define_module_function(module, "access_time", rb_access_time, 2);
    rb_define_module_function(module, "bit_ffs", bit_ffs, 1);
    rb_define_module_function(module, "bit_clz", bit_clz, 1);
    rb_define_module_function(module, "physmem_size", rb_mem_size, 0);
    rb_define_module_function(module, "get_cpu_freq", rb_get_cpu_freq, 0);
}

