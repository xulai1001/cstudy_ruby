#ifndef _TIMING_H
#define _TIMING_H

#include "time.h"
#include "stdio.h"
#include "unistd.h"
#include "linux/types.h"
#include "stdint.h"

typedef uint64_t clk_t;

struct myclock {
    // clock_gettime vars
    clk_t ns;
    int type;
    struct timespec t0, t1;
    // rdtsc vars
    clk_t ticks, r0, r1;
};

#ifndef _TIMING_VARS
#define _TIMING_VARS
clk_t clk_freq = -1;
#else
extern clk_t clk_freq;
#endif

#define START_CLOCK(cl, tp) cl.type = tp; clock_gettime(cl.type, &cl.t0)
#define END_CLOCK(cl) clock_gettime(cl.type, &cl.t1); \
    cl.ns = (cl.t1.tv_sec - cl.t0.tv_sec) * 1000000000 + (cl.t1.tv_nsec - cl.t0.tv_nsec)

// intel guide
// use cpuid as barrier before, cpuid will clobber(use) all registers
// shl/or joins eax/edx to 64-bit long
// no output vars
#define START_TSC(cl) __asm__ __volatile__ ( \
   "cpuid \n\
    rdtsc \n\
    shlq $32, %%rdx \n\
    orq %%rdx, %%rax" \
    : "=a"(cl.r0) \
    : \
    : "%rbx", "%rcx", "%rdx")

// shl/or joins eax/edx, then mov to var
// use cpuid as barrier after, will clobber all registers
// no output vars
// =g lets gcc decide howto deal with var
#define END_TSC(cl) __asm__ __volatile__ ( \
   "rdtscp \n\
    shlq $32, %%rdx \n\
    orq %%rdx, %%rax \n\
    movq %%rax, %0 \n\
    cpuid" \
    : "=g"(cl.r1) \
    : \
    : "%rax", "%rbx", "%rcx", "%rdx"); \
    cl.ticks = cl.r1 - cl.r0

// baseline test
clk_t clock_overhead(int type)
{
    struct myclock cl;
    clk_t i, sum=0;
    // warmup
    for (i=0; i<10; ++i)
    {
        START_CLOCK(cl, type);
        END_CLOCK(cl);
        sum += cl.ns;
    }
    sum = 0;
    // test
    for (i=0; i<100; ++i)
    {
        START_CLOCK(cl, type);
        END_CLOCK(cl);
        sum += cl.ns;
    }
    return sum/100;
}

clk_t tsc_overhead(void)
{
    struct myclock cl;
    clk_t i, sum=0;
    //warmup
    for (i=0; i<10; ++i)
    {
        START_TSC(cl);
        END_TSC(cl);
        sum += cl.ticks;
    }
    sum = 0;
    //test
    for (i=0; i<1000; ++i)
    {
        START_TSC(cl);
        END_TSC(cl);
        if (cl.ticks < 100)     // rule out big values
            sum += cl.ticks;
    }
    return sum/1000;
}

clk_t tsc_measure_freq(void)
{
    struct myclock cl;
    printf("tsc_measure_freq...");
    START_TSC(cl);
    usleep(1000000);
    END_TSC(cl);
    printf("%ld MHz(Mticks/sec)\n", cl.ticks / 1000000);
    return cl.ticks;
}

clk_t tsc_to_ns(clk_t ticks)
{
    if (clk_freq<0) clk_freq = tsc_measure_freq();
    return ticks * 1000000000 / clk_freq;    
}

#endif
