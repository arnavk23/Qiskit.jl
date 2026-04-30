# This code is part of Qiskit.
#
# (C) Copyright IBM 2025.
#
# This code is licensed under the Apache License, Version 2.0. You may
# obtain a copy of this license in the LICENSE.txt file in the root directory
# of this source tree or at http://www.apache.org/licenses/LICENSE-2.0.
#
# Any modifications or derivative works of this code must retain this
# copyright notice, and modified files need to carry a notice indicating
# that they have been altered from the originals.

@testset "Circuit" begin
    qc = QuantumCircuit(4, 1)
    @test qc.num_qubits == 4
    @test qc.num_clbits == 1
    @test qc.num_instructions == 0
    qc.rz(0.25, 4)
    qc.h(2)
    qk_circuit_gate(qc, QkGate_XXPlusYY, [2, 3], [0.3, 0])
    qk_circuit_delay(qc, 1, 1, QkDelayUnit_NS)
    qc.delay(2, 2.5, QkDelayUnit_US)
    qc.unitary([0 -im; im 0], [1])
    qc.barrier()
    qc.measure(4, 1)
    qc.reset(4)
    @test qc.num_instructions == 9
    instructions = [instruction.name for instruction in qc.data]
    @test instructions == ["rz", "h", "xx_plus_yy", "delay", "delay", "unitary", "barrier", "measure", "reset"]
    expected_op_counts = Dict(
        "rz" => 1,
        "h" => 1,
        "xx_plus_yy" => 1,
        "delay" => 2,
        "unitary" => 1,
        "barrier" => 1,
        "measure" => 1,
        "reset" => 1,
    )
    @test Dict(qk_circuit_count_ops(qc)) == expected_op_counts
    @test qc.count_ops() == expected_op_counts
    @test qk_circuit_get_instruction(qc, 1).params == [0.25]
    @test qk_circuit_get_instruction(qc, 3).params == [0.3, 0]
    @test qk_circuit_get_instruction(qc, 3).qubits == [2, 3]
    qc_copy = copy(qc)
    @test qc_copy.num_qubits == qc.num_qubits
    @test qc_copy.num_clbits == qc.num_clbits
    @test qc_copy.num_instructions == qc.num_instructions
    @testset "Zero-based indexing" begin
        qc = QuantumCircuit(4, 1, offset=0)
        @test qc.num_qubits == 4
        qc.rz(0.25, 0)
        qc.cx(0, 3)
        qc.delay(1, 4.0)
        qc.unitary([0 -im; im 0], [0])
        qc.barrier(0, 1, 2, 3)
        qc.measure(3, 0)
        qc.reset(0)
        @test_throws ArgumentError qc.h(4)
        @test_throws ArgumentError qk_circuit_unitary(qc, [0 1; 1 0], [4])
        @test_throws ArgumentError qk_circuit_barrier(qc, [1, 2, 3, 4])
        @test_throws ArgumentError qk_circuit_measure(qc, 4, 0)
        @test_throws ArgumentError qk_circuit_measure(qc, 3, 1)
        @test_throws ArgumentError qk_circuit_reset(qc, 4)
        instructions = [instruction.name for instruction in qc.data]
        @test instructions == ["rz", "cx", "delay", "unitary", "barrier", "measure", "reset"]
        @test qk_circuit_get_instruction(qc, 0).params == [0.25]
        @test qk_circuit_get_instruction(qc, 1).qubits == [0, 3]
        @test qk_circuit_get_instruction(qc, 2).params == [4.0]
        @test qk_circuit_get_instruction(qc, 5).clbits == [0]
    end
    
    # Unitful support tests - only run if Unitful is available
    if isdefined(@__MODULE__, :Unitful)
        @testset "Unitful support" begin
            qc = QuantumCircuit(4, 0)
            
            # Test direct unit matching - each unit type should be handled explicitly
            
            # Second unit (s)
            qc.delay(1, 1.5 * Unitful.s)
            @test qc.num_instructions == 1
            @test qc.data[1].name == "delay"
            
            # Millisecond unit (ms)
            qc.delay(2, 500 * Unitful.ms)
            @test qc.num_instructions == 2
            
            # Microsecond unit (μs)
            qc.delay(3, 10 * Unitful.μs)
            @test qc.num_instructions == 3
            
            # Nanosecond unit (ns)
            qc.delay(4, 5 * Unitful.ns)
            @test qc.num_instructions == 4
            
            # Picosecond unit (ps)
            qc.delay(1, 100 * Unitful.ps)
            @test qc.num_instructions == 5
            
            # Test fallback conversion for non-standard units (e.g., hours, days)
            # These should convert to seconds and select appropriate unit
            
            # Hour to microsecond (>= 1e-6)
            qc.delay(2, 0.001 * Unitful.u"hr")  # 3.6 seconds
            @test qc.num_instructions == 6
            
            # Minute to millisecond (>= 1e-3)
            qc.delay(3, 0.05 * Unitful.u"minute")  # 3 seconds
            @test qc.num_instructions == 7
            
            # Millisecond via direct ms unit
            qc.delay(4, 0.5 * Unitful.ms)
            @test qc.num_instructions == 8
            
            # Test edge cases for conversion thresholds
            # Just at 1e-3 boundary (1 ms)
            qc.delay(1, 1e-3 * Unitful.s)
            @test qc.num_instructions == 9
            
            # Just below 1e-3 boundary (0.999 ms)
            qc.delay(2, 0.999e-3 * Unitful.s)
            @test qc.num_instructions == 10
            
            # Very small value (picoseconds range)
            qc.delay(3, 1e-12 * Unitful.s)
            @test qc.num_instructions == 11
        end
    end
end
