#include "sel4.h"

#define seL4_Word unsigned long
#define MCS_REPLY_DECL register seL4_Word reply_reg asm("r12") = reply
#define MCS_REPLY ,"r"(reply_reg)

static inline void x64_sys_send_recv(seL4_Word sys, seL4_Word dest, seL4_Word *out_dest, seL4_Word info,
                                     seL4_Word *out_info, seL4_Word *in_out_mr0, seL4_Word *in_out_mr1, seL4_Word *in_out_mr2, seL4_Word *in_out_mr3,
                                      seL4_Word reply)
{
    register seL4_Word mr0 asm("r10") = *in_out_mr0;
    register seL4_Word mr1 asm("r8") = *in_out_mr1;
    register seL4_Word mr2 asm("r9") = *in_out_mr2;
    register seL4_Word mr3 asm("r15") = *in_out_mr3;
    MCS_REPLY_DECL;

    asm volatile(
        "movq   %%rsp, %%rbx    \n"
        "syscall                \n"
        "movq   %%rbx, %%rsp    \n"
        : "=S"(*out_info),
        "=r"(mr0),
        "=r"(mr1),
        "=r"(mr2),
        "=r"(mr3),
        "=D"(*out_dest)
        : "d"(sys),
        "D"(dest),
        "S"(info),
        "r"(mr0),
        "r"(mr1),
        "r"(mr2),
        "r"(mr3)
        MCS_REPLY
        : "%rcx", "%rbx", "r11", "memory"
    );
    *in_out_mr0 = mr0;
    *in_out_mr1 = mr1;
    *in_out_mr2 = mr2;
    *in_out_mr3 = mr3;
}

void seL4_DebugPutChar(char c)
{
    seL4_Word unused0 = 0;
    seL4_Word unused1 = 0;
    seL4_Word unused2 = 0;
    seL4_Word unused3 = 0;
    seL4_Word unused4 = 0;
    seL4_Word unused5 = 0;

    x64_sys_send_recv(-9, c, &unused0, 0, &unused1, &unused2, &unused3, &unused4, &unused5, 0);
}


void seL4_DebugPutString(char *str)
{
    for (char *s = str; *s; s++) {
        seL4_DebugPutChar(*s);
    }
    return;
}
