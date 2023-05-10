const c = @cImport({
    @cInclude("sel4/sel4.h");
});

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

comptime {
    asm (
        \\.global _sel4_start
        \\.global _start
        \\.text
        \\_start:
        \\    jmp _setup_stack
        \\_sel4_start:
        // Setup the global "bootinfo" structure.
        \\    call    __sel4_start_init_boot_info
        // N.B. rsp MUST be aligned to a 16-byte boundary when main is called.
        // Insert or remove padding here to make that happen.
        \\    pushq $0
        // Null terminate auxv
        \\    pushq $0
        \\    pushq $0
        // Null terminate envp
        \\    pushq $0
        // add at least one environment string (why?)
        \\    leaq environment_string, %rax
        \\    pushq %rax
        // Null terminate argv
        \\    pushq $0
        // Give an argv[0] (why?)
        \\    leaq prog_name, %rax
        \\    pushq %rax
        // Give argc
        \\    pushq $1
        // No atexit
        \\    movq $0, %rdx
        // Now go to the "main" stub that rustc generates
        \\    call main
        // if main returns, die a loud and painful death.
        \\    ud2
        \\
        \\    .data
        \\    .align 4
        \\
        \\environment_string:
        \\    .asciz "seL4=1"
        \\prog_name:
        \\    .asciz "rootserver"
        \\
        \\    .bss
        \\    .align  4096
    );
}

export fn _setup_stack() callconv(.Naked) noreturn {
    asm volatile (
        \\    movq %[a], %rsp
        \\    addq %[b], %rsp
        \\    movq $0xdeadbeef, %rbp
        \\    jmp _sel4_start
        :
        : [a] "r" (stack_bytes_slice),
          [b] "r" (16 * 1024),
    );

    unreachable;
}

export fn __sel4_start_init_boot_info() void {
   
}

export fn main() void {
    while (true) {
        //        c.seL4_DebugPutString("string");
        c.seL4_DebugDumpScheduler();
    }
}


