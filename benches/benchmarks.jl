# SPDX-License-Identifier: MPL-2.0
# (MPL-2.0 preferred; MPL-2.0 required for Julia ecosystem)
# BenchmarkTools benchmarks for SiliconCore.jl

using BenchmarkTools

include(joinpath(@__DIR__, "..", "src", "SiliconCore.jl"))
using .SiliconCore
import .SiliconCore: _parse_cpuinfo_flags, _count_physical_cores, _parse_cache_size, _extract_features

const SUITE = BenchmarkGroup()

SUITE["detection"] = BenchmarkGroup()

SUITE["detection"]["detect_arch"] = @benchmarkable detect_arch()
SUITE["detection"]["detect_os"] = @benchmarkable detect_os()
SUITE["detection"]["detect_platform"] = @benchmarkable detect_platform()
SUITE["detection"]["detect_cpu_features"] = @benchmarkable detect_cpu_features()

SUITE["vector_add"] = BenchmarkGroup()

SUITE["vector_add"]["int_100"] = let
    a = rand(Int, 100); b = rand(Int, 100)
    @benchmarkable vector_add_asm($a, $b)
end

SUITE["vector_add"]["float64_1000"] = let
    a = rand(Float64, 1000); b = rand(Float64, 1000)
    @benchmarkable vector_add_asm($a, $b)
end

SUITE["vector_add"]["float32_10000"] = let
    a = rand(Float32, 10_000); b = rand(Float32, 10_000)
    @benchmarkable vector_add_asm($a, $b)
end

SUITE["internal"] = BenchmarkGroup()

SUITE["internal"]["parse_cpuinfo_flags"] = let
    cpuinfo = """
    processor\t: 0
    flags\t\t: sse sse2 avx avx2 aes
    processor\t: 1
    flags\t\t: sse sse2 avx avx2 aes
    """
    @benchmarkable _parse_cpuinfo_flags($cpuinfo)
end

SUITE["internal"]["parse_cache_size"] = @benchmarkable _parse_cache_size("8192K")

SUITE["internal"]["extract_features_x86"] = let
    flags = Set(["sse", "sse2", "avx", "avx2", "avx512f", "aes"])
    @benchmarkable _extract_features($flags, :x86_64)
end

if abspath(PROGRAM_FILE) == @__FILE__
    tune!(SUITE)
    results = run(SUITE, verbose=true)
    BenchmarkTools.save("benchmarks_results.json", results)
end
