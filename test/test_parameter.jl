# This code is part of Qiskit.
#
# (C) Copyright IBM 2025.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of the License in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

@testset "Parameter" begin
    @testset "Construction and display" begin
        symbol = Parameter("theta")
        numeric = Parameter(2.5)
        complex_value = Parameter(1 + 2im)

        @test occursin("theta", sprint(show, symbol))
        @test occursin("theta", sprint(show, MIME"text/plain"(), symbol))
        @test sprint(show, numeric) == "Parameter(2.5)"
        @test Float64(numeric) == 2.5
        @test Float64(complex_value) == 1.0
        @test symbol == copy(symbol)
        @test numeric == 2.5

        freed = Parameter("free_me")
        qk_param_free(freed)
        @test sprint(show, freed) == "Parameter(NULL)"
    end

    @testset "Arithmetic" begin
        a = Parameter("a")
        b = Parameter("b")

        sum = a + b
        diff = a - b
        product = a * 2
        quotient = 2 / a
        power = a ^ 2
        negated = -a
        s = sin(a)
        c = cos(a)
        e = exp(a)

        @test occursin("a", string(sum))
        @test occursin("b", string(sum))
        @test occursin("-", string(diff))
        @test occursin("2", string(product))
        @test occursin("/", string(quotient))
        @test occursin("^", string(power)) || occursin("pow", string(power))
        @test occursin("-", string(negated))
        @test occursin("sin", string(s))
        @test occursin("cos", string(c))
        @test occursin("exp", string(e))
    end
end
