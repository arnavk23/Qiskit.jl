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

@testset "DAGCircuit" begin
    @testset "Construction from QuantumCircuit" begin
        qc = QuantumCircuit(3, 2)
        qc.h(1)
        qc.cx(1, 2)
        qc.rz(0.5, 3)
        qc.measure(1, 1)
        qc.measure(2, 2)
        qc.barrier()

        dag = DAGCircuit(qc)
        @test dag.num_qubits == 3
        @test dag.num_clbits == 2
        @test dag.num_op_nodes == 6
        @test length(dag) == 6
        @test !isempty(dag)
    end

    @testset "Empty circuit" begin
        qc = QuantumCircuit(2, 1)
        dag = DAGCircuit(qc)
        @test dag.num_qubits == 2
        @test dag.num_clbits == 1
        @test dag.num_op_nodes == 0
        @test isempty(dag)
        @test length(dag) == 0
    end

    @testset "Round-trip circuit -> dag -> circuit" begin
        qc = QuantumCircuit(3, 1)
        qc.h(1)
        qc.cx(1, 2)
        qc.rz(0.25, 3)
        qc.measure(3, 1)

        dag = DAGCircuit(qc)
        qc2 = QuantumCircuit(dag)
        @test qc2.num_qubits == qc.num_qubits
        @test qc2.num_clbits == qc.num_clbits
        @test qc2.num_instructions == qc.num_instructions

        names1 = [inst.name for inst in qc.data]
        names2 = [inst.name for inst in qc2.data]
        @test names1 == names2
    end

    @testset "Iteration and node properties" begin
        qc = QuantumCircuit(3, 1)
        qc.h(1)
        qc.cx(1, 2)
        qc.measure(2, 1)

        dag = DAGCircuit(qc)
        nodes = collect(dag)
        @test length(nodes) == 3

        names = [n.name for n in nodes]
        @test "h" in names
        @test "cx" in names
        @test "measure" in names

        for node in nodes
            @test node isa DAGNode
            @test !isempty(node.name)
            @test node.num_qubits >= 0
            @test node.num_clbits >= 0
            @test node.num_params >= 0
        end

        h_node = nodes[findfirst(n -> n.name == "h", nodes)]
        @test h_node.num_qubits == 1
        @test h_node.num_params == 0

        cx_node = nodes[findfirst(n -> n.name == "cx", nodes)]
        @test cx_node.num_qubits == 2
        @test cx_node.num_params == 0

        m_node = nodes[findfirst(n -> n.name == "measure", nodes)]
        @test m_node.num_qubits == 1
        @test m_node.num_clbits == 1
    end

    @testset "Node with parameters" begin
        qc = QuantumCircuit(2)
        qc.rz(0.75, 1)
        qc.rx(1.5, 2)

        dag = DAGCircuit(qc)
        nodes = collect(dag)

        rz_node = nodes[findfirst(n -> n.name == "rz", nodes)]
        @test rz_node.params == [0.75]
        @test rz_node.num_params == 1

        rx_node = nodes[findfirst(n -> n.name == "rx", nodes)]
        @test rx_node.params == [1.5]
        @test rx_node.num_params == 1
    end

    @testset "Base.show" begin
        qc = QuantumCircuit(2, 1)
        qc.h(1)
        qc.measure(1, 1)

        dag = DAGCircuit(qc)

        # Compact form
        io = IOBuffer()
        show(io, dag)
        output = String(take!(io))
        @test output == "DAGCircuit(2, 1; 2 nodes)"

        # text/plain form
        io = IOBuffer()
        show(io, MIME"text/plain"(), dag)
        output = String(take!(io))
        @test startswith(output, "DAGCircuit with 2 qubits, 1 clbits")
        @test contains(output, "nodes: 2")

        # NULL path
        qk_dag_free(dag)
        io = IOBuffer()
        show(io, dag)
        @test String(take!(io)) == "DAGCircuit(NULL)"
    end

    @testset "Node show" begin
        qc = QuantumCircuit(3, 1)
        qc.h(1)
        qc.cx(1, 2)
        qc.measure(2, 1)

        dag = DAGCircuit(qc)
        nodes = collect(dag)

        h_node = nodes[findfirst(n -> n.name == "h", nodes)]
        io = IOBuffer()
        show(io, h_node)
        @test contains(String(take!(io)), "h")

        cx_node = nodes[findfirst(n -> n.name == "cx", nodes)]
        io = IOBuffer()
        show(io, cx_node)
        output = String(take!(io))
        @test contains(output, "cx")
        @test contains(output, "qubits")

        m_node = nodes[findfirst(n -> n.name == "measure", nodes)]
        io = IOBuffer()
        show(io, m_node)
        output = String(take!(io))
        @test contains(output, "measure")
        @test contains(output, "clbits")
    end

    @testset "propertynames" begin
        qc = QuantumCircuit(2)
        dag = DAGCircuit(qc)
        @test :num_qubits in propertynames(dag)
        @test :num_clbits in propertynames(dag)
        @test :num_op_nodes in propertynames(dag)

        nodes = collect(dag)
        if !isempty(nodes)
            @test :name in propertynames(nodes[1])
            @test :qubits in propertynames(nodes[1])
            @test :clbits in propertynames(nodes[1])
            @test :params in propertynames(nodes[1])
        end
    end

    @testset "Low-level C API" begin
        qc = QuantumCircuit(2, 1)
        qc.h(1)
        qc.cx(1, 2)
        qc.measure(1, 1)

        dag_ptr = qk_circuit_to_dag(qc.ptr)
        @test dag_ptr != C_NULL
        @test qk_dag_num_qubits(dag_ptr) == 2
        @test qk_dag_num_clbits(dag_ptr) == 1
        @test qk_dag_num_op_nodes(dag_ptr) == 3

        order = qk_dag_topological_op_nodes(dag_ptr)
        @test length(order) == 3

        qc2_ptr = qk_dag_to_circuit(dag_ptr)
        @test qc2_ptr != C_NULL

        qk_dag_free(dag_ptr)
    end
end
