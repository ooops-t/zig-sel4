const std = @import("std");

pub fn build(b: *std.Build) void {
    var target: std.zig.CrossTarget = .{
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
        .cpu_model = .{ .explicit = &std.Target.x86.cpu.nehalem },
        .abi = .none,
    };

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "rootserver",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.stack_size = 0; // Set the GUN_STACK elf header size to zero
    exe.entry_symbol_name = "_start";
    exe.setLinkerScriptPath(.{ .path = "src/tls_rootserver.lds" });
    //    exe.addIncludePath("src");
    //    exe.addCSourceFile("src/sel4.c", &[_][]const u8{"-Wall", "-Wextra", "-Werror"});
    const kernel_path = "/home/cheney/nfs/notebook/seL4/seL4-demo/kernel"; 
    exe.addIncludePath(kernel_path ++ "/libsel4/include/");
    exe.addIncludePath(kernel_path ++ "/libsel4/mode_include/64/");
    exe.addIncludePath(kernel_path ++ "/libsel4/arch_include/x86/");
    exe.addIncludePath(kernel_path ++ "/libsel4/sel4_arch_include/x86_64/");
    exe.addIncludePath(kernel_path ++ "/libsel4/sel4_plat_include/pc99/");

    const build_path = "/home/cheney/nfs/notebook/seL4/seL4-demo/build";
    exe.addIncludePath(build_path ++ "/kernel/gen_config/");
    exe.addIncludePath(build_path ++ "/libsel4/include/");
    exe.addIncludePath(build_path ++ "/libsel4/autoconf/");
    exe.addIncludePath(build_path ++ "/libsel4/gen_config/");
    exe.addIncludePath(build_path ++ "/libsel4/arch_include/x86/");
    exe.addIncludePath(build_path ++ "/libsel4/sel4_arch_include/x86_64/");

    exe.addLibraryPath(build_path ++ "/libsel4/");
    exe.linkSystemLibrary("sel4");
    b.installArtifact(exe);
}
