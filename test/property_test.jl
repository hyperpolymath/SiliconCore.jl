# SPDX-License-Identifier: MPL-2.0
# (MPL-2.0 preferred; MPL-2.0 required for Julia ecosystem)
# Property-based invariant tests for SiliconCore.jl

using Test

include(joinpath(@__DIR__, "..", "src", "SiliconCore.jl"))
using .SiliconCore
import .SiliconCore: _parse_cache_size, _extract_features, _make_minimal_features

@testset "Property-Based Tests" begin

    @testset "Invariant: vector_add_asm is commutative" begin
        for _ in 1:50
            n = rand(1:100)
            a = rand(Int, n)
            b = rand(Int, n)
            @test vector_add_asm(a, b) == vector_add_asm(b, a)
        end
    end

    @testset "Invariant: vector_add_asm(a, zeros) == a" begin
        for _ in 1:50
            n = rand(1:100)
            a = rand(Int, n)
            z = zeros(Int, n)
            @test vector_add_asm(a, z) == a
        end
    end

    @testset "Invariant: _parse_cache_size is non-negative" begin
        for _ in 1:50
            n = rand(1:8192)
            for suffix in ["K", "M", "G", ""]
                result = _parse_cache_size("$(n)$(suffix)")
                @test result >= 0
            end
        end
    end

    @testset "Invariant: detect_cpu_features returns consistent thread count" begin
        for _ in 1:20
            features = detect_cpu_features()
            @test features.num_threads >= 1
            @test features.num_cores >= 1
            @test features.num_threads >= features.num_cores
        end
    end

    @testset "Invariant: _make_minimal_features thread count matches input" begin
        for _ in 1:50
            threads = rand(1:128)
            f = _make_minimal_features(:x86_64, threads, :linux)
            @test f.num_threads == threads
        end
    end

end
