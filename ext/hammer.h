#ifndef _HAMMER_H
#define _HAMMER_H

#include "timing.h"

// primitive
#define HAMMER(a, b) __asm__ __volatile__( \
    "movq (%0), %%rax \n\t" \
    "movq (%1), %%rax \n\t" \
    "clflush (%0) \n\t" \
    "clflush (%1) \n\t" \
    :   \
    :"r"(a), "r"(b) \
    :"rax", "memory")

#define HAMMER_fence(a, b) __asm__ __volatile__( \
    "movq (%0), %%rax \n\t" \
    "movq (%1), %%rax \n\t" \
    "clflush (%0) \n\t" \
    "clflush (%1) \n\t" \
    "mfence" \
    :   \
    :"r"(a), "r"(b) \
    :"rax", "memory")


// row conflict (slow path) > 250 ticks
#define ACCESS_TIME_THRESHOLD 250

// hammer function. returns operation time (ticks)
uint64_t hammer_loop(void *va, void *vb, int n, int delay)
{
    struct myclock clk;
    register int i = n, j;
    
    START_TSC(clk);
    while (i--) {
        j = delay;
        HAMMER(va, vb); 
        while (j-- > 0);
    }
    END_TSC(clk);
    
    return clk.ticks;
}

// hammer function. returns operation time (ticks)
uint64_t hammer_loop_fence(void *va, void *vb, int n, int delay)
{
    struct myclock clk;
    register int i = n, j;
    
    START_TSC(clk);
    while (i--) {
        j = delay;
        HAMMER_fence(va, vb); 
        while (j-- > 0);
    }
    END_TSC(clk);
    
    return clk.ticks;
}

// method from OBF (usenix 16)
// given 2 virt addrs, measure their average access time by hammering
/*
int is_row_conflict(void *va, void *vb, int *out)
{
    int access_time;
    access_time = hammer_loop(va, vb, 200) / (200*2);
    while (access_time > 2*ACCESS_TIME_THRESHOLD)
    {
        //printf("access time too long (%d), retry...\n", access_time);
        access_time = hammer_loop(va, vb, 200) / (200*2);
    }
    if (out) *out = access_time;
    return (access_time >= ACCESS_TIME_THRESHOLD);
}
*/

#endif
