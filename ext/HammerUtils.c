#include "ruby.h"
#include "unistd.h"
#include "errno.h"
#include "stdint.h"
#include "fcntl.h"
#include "sys/mman.h"
#include "time.h"
#include "stdio.h"
#include "linux/types.h"

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
    
    int dummy = *(int *)v;  // visit the addr, keep it in memory
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
    return ULL2NUM((uint64_t)v);
}

static VALUE release(VALUE self)
{
    void *v = (void *)NUM2ULL(rb_iv_get(self, "@v"));
    munmap(v, ALLOC_SIZE);
    rb_iv_set(self, "@v", INT2FIX(0));  //actually int 1
    rb_iv_set(self, "@p", INT2FIX(0));
    return self;
}

void Init_HammerUtils()
{
    module = rb_define_module("HammerUtils");   // module HammerUtils
    page_class = rb_define_class_under(module, "Page", rb_cObject);     // class Page
    rb_define_attr(page_class, "v", 1, 0);  // attr_reader :v
    rb_define_attr(page_class, "p", 1, 0);  // attr_reader :p
    rb_define_method(page_class, "initialize", initialize, 0);
    rb_define_method(page_class, "acquire", acquire, 0);
    rb_define_method(page_class, "release", release, 0);
}


