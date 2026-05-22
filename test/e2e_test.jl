# SPDX-License-Identifier: MPL-2.0
# (MPL-2.0 preferred; MPL-2.0 required for Julia ecosystem)
# E2E pipeline tests for SiliconCore.jl

using Test

include(joinpath(@__DIR__, "..", "src", "SiliconCore.jl"))
using .SiliconCore

@testset "E2E Pipeline Tests" begin

    @testset "Full detection pipeline" begin
        # Detect all platform info in a single pipeline
        arch = detect_arch()
        os = detect_os()
        platform = detect_platform()
        features = detect_cpu_features()

        @test arch isa Symbol
        @test os isa Symbol
        @test platform isa Symbol
        @test features isa CpuFeatures

        # features must be consistent with top-level detectors
        @test features.arch === arch
        @test features.os === os
        @test features.platform === platform
    end

    @testset "Vector arithmetic pipeline" begin
        # Build arrays of different sizes and types; add them; verify results
        for n in [1, 10, 100, 1000]
            a = collect(1:n)
            b = collect(n:-1:1)
            result = vector_add_asm(a, b)
            @test all(result .== n + 1)
        end

        for T in [Int32, Int64, Float32, Float64]
            a = T.(1:50)
            b = T.(50:-1:1)
            result = vector_add_asm(a, b)
            @test all(result .== T(51))
        end
    end

    @testset "Feature query pipeline" begin
        features = detect_cpu_features()
        # Every supported feature can be queried without error
        for name in [:sse, :sse2, :avx, :avx2, :avx512f, :avx512vl, :avx512bw,
                     :amx, :aesni, :neon, :sve, :sve2, :sme, :rvv, :rvv_1_0,
                     :altivec, :vsx]
            result = has_feature(features, name)
            @test result isa Bool
        end
    end

    @testset "Error handling: unknown feature raises ErrorException" begin
        features = detect_cpu_features()
        @test_throws ErrorException has_feature(features, :nonexistent_feature_xyz)
    end

end
