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

import .LibQiskit: QkBitTerm, QkComplex64, QkObs, QkObsTerm

function check_not_null(obs::Ptr{QkObs})::Nothing
    if obs == C_NULL
        throw(ArgumentError("Ptr{QkObs} is NULL."))
    end
    nothing
end

to_qk_complex64(value::QkComplex64) = value
to_qk_complex64(value::Number) = QkComplex64(real(ComplexF64(value)), imag(ComplexF64(value)))

function qk_bitterm_label(bit_term::QkBitTerm)::Char
    @ccall libqiskit.qk_bitterm_label(bit_term::UInt8)::UInt8
end

function qk_obs_identity(n::Integer)
    n >= 0 || throw(ArgumentError("num_qubits must be non-negative."))
    @ccall libqiskit.qk_obs_identity(n::UInt32)::Ptr{QkObs}
end

function qk_obs_free(obs::Ptr{QkObs})
    @ccall libqiskit.qk_obs_free(obs::Ptr{QkObs})::Cvoid
end

function qk_obs_zero(n::Integer)
    n >= 0 || throw()
    @ccall libqiskit.qk_obs_zero(n::UInt32)::Ptr{QkObs}
end

function qk_obs_add_term(obs::Ptr{QkObs}, term::QkObsTerm)
    check_not_null(obs)
    check_exit_code(@ccall libqiskit.qk_obs_add_term(obs::Ptr{QkObs}, Ref(term)::Ref{QkObsTerm})::QkExitCode)
    nothing
end

function qk_obs_new(num_qubits::Integer, num_terms::Integer, num_bits::Integer, coeffs, bit_terms, indices, boundaries)
    num_qubits >= 0 || throw(ArgumentError("num_qubits must be non-negative."))
    num_terms >= 0 || throw(ArgumentError("num_terms must be non-negative."))
    num_bits >= 0 || throw(ArgumentError("num_bits must be non-negative."))

    coeffs0 = num_terms == 0 ? C_NULL : Vector{QkComplex64}(to_qk_complex64.(coeffs))
    bit_terms0 = num_bits == 0 ? C_NULL : Vector{QkBitTerm}(bit_terms)
    indices0 = num_bits == 0 ? C_NULL : Vector{UInt32}(indices)
    boundaries0 = Vector{Csize_t}(boundaries)

    if num_terms > 0 && length(coeffs0) != num_terms
        throw(ArgumentError("num_terms does not match length(coeffs)."))
    end
    if num_bits > 0 && length(bit_terms0) != num_bits
        throw(ArgumentError("num_bits does not match length(bit_terms)."))
    end
    if num_bits > 0 && length(indices0) != num_bits
        throw(ArgumentError("num_bits does not match length(indices)."))
    end
    if length(boundaries0) != num_terms + 1
        throw(ArgumentError("boundaries must have length num_terms + 1."))
    end

    @ccall libqiskit.qk_obs_new(
        num_qubits::UInt32,
        num_terms::Csize_t,
        num_bits::Csize_t,
        coeffs0::Ptr{QkComplex64},
        bit_terms0::Ptr{QkBitTerm},
        indices0::Ptr{UInt32},
        boundaries0::Ptr{Csize_t}
    )::Ptr{QkObs}
end

function qk_obs_copy(obs::Ptr{QkObs})
    check_not_null(obs)
    @ccall libqiskit.qk_obs_copy(obs::Ptr{QkObs})::Ptr{QkObs}
end

function qk_obs_add(left::Ptr{QkObs}, right::Ptr{QkObs})
    check_not_null(left)
    check_not_null(right)
    @ccall libqiskit.qk_obs_add(left::Ptr{QkObs}, right::Ptr{QkObs})::Ptr{QkObs}
end

function qk_obs_add_inplace(left::Ptr{QkObs}, right::Ptr{QkObs})
    check_not_null(left)
    check_not_null(right)
    @ccall libqiskit.qk_obs_add_inplace(left::Ptr{QkObs}, right::Ptr{QkObs})::Cvoid
end

function qk_obs_scaled_add(left::Ptr{QkObs}, right::Ptr{QkObs}, factor::QkComplex64)
    check_not_null(left)
    check_not_null(right)
    @ccall libqiskit.qk_obs_scaled_add(left::Ptr{QkObs}, right::Ptr{QkObs}, factor::Ref{QkComplex64})::Ptr{QkObs}
end

function qk_obs_scaled_add_inplace(left::Ptr{QkObs}, right::Ptr{QkObs}, factor::QkComplex64)
    check_not_null(left)
    check_not_null(right)
    @ccall libqiskit.qk_obs_scaled_add_inplace(left::Ptr{QkObs}, right::Ptr{QkObs}, factor::Ref{QkComplex64})::Cvoid
end

function qk_obs_multiply(obs::Ptr{QkObs}, factor::QkComplex64)
    check_not_null(obs)
    @ccall libqiskit.qk_obs_multiply(obs::Ptr{QkObs}, factor::Ref{QkComplex64})::Ptr{QkObs}
end

function qk_obs_multiply_inplace(obs::Ptr{QkObs}, factor::QkComplex64)
    check_not_null(obs)
    @ccall libqiskit.qk_obs_multiply_inplace(obs::Ptr{QkObs}, factor::Ref{QkComplex64})::Cvoid
end

function qk_obs_compose(first::Ptr{QkObs}, second::Ptr{QkObs})
    check_not_null(first)
    check_not_null(second)
    @ccall libqiskit.qk_obs_compose(first::Ptr{QkObs}, second::Ptr{QkObs})::Ptr{QkObs}
end

function qk_obs_compose_map(first::Ptr{QkObs}, second::Ptr{QkObs}, qargs)
    check_not_null(first)
    check_not_null(second)
    qargs0 = Vector{UInt32}(qargs)
    if length(qargs0) != qk_obs_num_qubits(second)
        throw(ArgumentError("qargs must have length equal to the number of qubits in the second observable."))
    end
    @ccall libqiskit.qk_obs_compose_map(first::Ptr{QkObs}, second::Ptr{QkObs}, qargs0::Ref{UInt32})::Ptr{QkObs}
end

function qk_obs_apply_layout(obs::Ptr{QkObs}, layout, num_qubits::Integer)
    check_not_null(obs)
    num_qubits >= 0 || throw(ArgumentError("num_qubits must be non-negative."))
    layout0 = Vector{UInt32}(layout)
    if length(layout0) != qk_obs_num_qubits(obs)
        throw(ArgumentError("layout must have length equal to the number of qubits in the observable."))
    end
    check_exit_code(@ccall libqiskit.qk_obs_apply_layout(obs::Ptr{QkObs}, layout0::Ref{UInt32}, num_qubits::UInt32)::QkExitCode)
    nothing
end

function qk_obs_canonicalize(obs::Ptr{QkObs}, tol::Real)
    check_not_null(obs)
    @ccall libqiskit.qk_obs_canonicalize(obs::Ptr{QkObs}, tol::Cdouble)::Ptr{QkObs}
end

function qk_obs_equal(obs::Ptr{QkObs}, other::Ptr{QkObs})::Bool
    check_not_null(obs)
    check_not_null(other)
    @ccall libqiskit.qk_obs_equal(obs::Ptr{QkObs}, other::Ptr{QkObs})::Bool
end

function qk_obs_coeffs(obs::Ptr{QkObs})
    check_not_null(obs)
    @ccall libqiskit.qk_obs_coeffs(obs::Ptr{QkObs})::Ptr{QkComplex64}
end

function qk_obs_indices(obs::Ptr{QkObs})
    check_not_null(obs)
    @ccall libqiskit.qk_obs_indices(obs::Ptr{QkObs})::Ptr{UInt32}
end

function qk_obs_bit_terms(obs::Ptr{QkObs})
    check_not_null(obs)
    @ccall libqiskit.qk_obs_bit_terms(obs::Ptr{QkObs})::Ptr{QkBitTerm}
end

function qk_obs_boundaries(obs::Ptr{QkObs})
    check_not_null(obs)
    @ccall libqiskit.qk_obs_boundaries(obs::Ptr{QkObs})::Ptr{Csize_t}
end

function qk_obs_term(obs::Ptr{QkObs}, index::Integer)::QkObsTerm
    check_not_null(obs)
    index >= 0 || throw(ArgumentError("index must be non-negative."))
    term = Ref{QkObsTerm}()
    check_exit_code(@ccall libqiskit.qk_obs_term(obs::Ptr{QkObs}, index::Csize_t, term::Ref{QkObsTerm})::QkExitCode)
    term[]
end

function qk_obs_str(obs::Ptr{QkObs})::String
    check_not_null(obs)
    string = @ccall libqiskit.qk_obs_str(obs::Ptr{QkObs})::Ptr{Cchar}
    retval = unsafe_string(string)
    qk_str_free(string)
    retval
end

function qk_obsterm_str(term::QkObsTerm)::String
    string = @ccall libqiskit.qk_obsterm_str(Ref(term)::Ref{QkObsTerm})::Ptr{Cchar}
    retval = unsafe_string(string)
    qk_str_free(string)
    retval
end

function qk_obs_num_terms(obs::Ptr{QkObs})::Int
    check_not_null(obs)
    signed(@ccall libqiskit.qk_obs_num_terms(obs::Ptr{QkObs})::Csize_t)
end

function qk_obs_num_qubits(obs::Ptr{QkObs})::Int
    check_not_null(obs)
    signed(@ccall libqiskit.qk_obs_num_qubits(obs::Ptr{QkObs})::UInt32)
end

function qk_obs_len(obs::Ptr{QkObs})::Int
    check_not_null(obs)
    signed(@ccall libqiskit.qk_obs_len(obs::Ptr{QkObs})::Csize_t)
end

export QkBitTerm, qk_bitterm_label, QkObs, qk_obs_free, qk_obs_zero, qk_obs_identity, qk_obs_new, qk_obs_add_term, qk_obs_copy, qk_obs_add, qk_obs_add_inplace, qk_obs_scaled_add, qk_obs_scaled_add_inplace, qk_obs_multiply, qk_obs_multiply_inplace, qk_obs_compose, qk_obs_compose_map, qk_obs_apply_layout, qk_obs_canonicalize, qk_obs_equal, qk_obs_str, qk_obsterm_str
export qk_obs_num_terms, qk_obs_num_qubits, qk_obs_len, qk_obs_coeffs, qk_obs_indices, qk_obs_bit_terms, qk_obs_boundaries, qk_obs_term

# Export enum instances
for e in (QkBitTerm,)
    for s in instances(e)
        @eval import .LibQiskit: $(Symbol(s))
        @eval export $(Symbol(s))
    end
end
