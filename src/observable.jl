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

import .C: qk_obs_free, qk_obs_num_terms, qk_obs_num_qubits, qk_obs_zero, qk_obs_len, qk_obs_identity, qk_obs_new, qk_obs_add_term, qk_obs_copy, qk_obs_add, qk_obs_add_inplace, qk_obs_scaled_add, qk_obs_scaled_add_inplace, qk_obs_multiply, qk_obs_multiply_inplace, qk_obs_compose, qk_obs_compose_map, qk_obs_apply_layout, qk_obs_canonicalize, qk_obs_equal, qk_obs_coeffs, qk_obs_indices, qk_obs_bit_terms, qk_obs_boundaries, qk_obs_term, qk_obs_str, qk_obsterm_str, QkObs, QkComplex64, QkObsTerm

"""
    SparseObservable

Qiskit observable.  This is a wrapper of `QkObs`, which is similar to
`SparseObservable` in Python.
"""
mutable struct SparseObservable
    ptr::Ptr{QkObs}
    @doc"""
        SparseObservable(n::Integer)

    Construct an empty `SparseObservable` on `n` qubits.
    """
    function SparseObservable(n::Integer)
        obs = new(qk_obs_zero(n))
        finalizer(qk_obs_free, obs)
        obs
    end
    function SparseObservable(ptr::Ptr{QkObs})
        check_not_null_obs(ptr)
        obs = new(ptr)
        finalizer(qk_obs_free, obs)
        obs
    end
end

function check_not_null_obs(qc::Ptr{QkObs})::Nothing
    if qc == C_NULL
        throw(ArgumentError("Ptr{QkObs} is NULL."))
    end
    nothing
end

function qk_obs_free(obs::SparseObservable)::Nothing
    if obs.ptr != C_NULL
        qk_obs_free(obs.ptr)
        obs.ptr = C_NULL
    end
    nothing
end

function qk_obs_num_terms(obs::SparseObservable)::Int
    check_not_null_obs(obs.ptr)
    qk_obs_num_terms(obs.ptr)
end

function qk_obs_num_qubits(obs::SparseObservable)::Int
    check_not_null_obs(obs.ptr)
    qk_obs_num_qubits(obs.ptr)
end

function qk_obs_len(obs::SparseObservable)::Int
    check_not_null_obs(obs.ptr)
    qk_obs_len(obs.ptr)
end

to_qk_complex64(value::QkComplex64) = value
to_qk_complex64(value::Number) = QkComplex64(real(ComplexF64(value)), imag(ComplexF64(value)))

function qk_obs_copy(obs::SparseObservable)::SparseObservable
    SparseObservable(qk_obs_copy(obs.ptr))
end

function qk_obs_add(left::SparseObservable, right::SparseObservable)::SparseObservable
    SparseObservable(qk_obs_add(left.ptr, right.ptr))
end

function qk_obs_add_inplace(left::SparseObservable, right::SparseObservable)::Nothing
    qk_obs_add_inplace(left.ptr, right.ptr)
    nothing
end

function qk_obs_add_term(obs::SparseObservable, term::QkObsTerm)::Nothing
    qk_obs_add_term(obs.ptr, term)
    nothing
end

function qk_obs_scaled_add(left::SparseObservable, right::SparseObservable, factor::Number)::SparseObservable
    SparseObservable(qk_obs_scaled_add(left.ptr, right.ptr, to_qk_complex64(factor)))
end

function qk_obs_scaled_add_inplace(left::SparseObservable, right::SparseObservable, factor::Number)::Nothing
    qk_obs_scaled_add_inplace(left.ptr, right.ptr, to_qk_complex64(factor))
    nothing
end

function qk_obs_multiply(obs::SparseObservable, factor::Number)::SparseObservable
    SparseObservable(qk_obs_multiply(obs.ptr, to_qk_complex64(factor)))
end

function qk_obs_multiply_inplace(obs::SparseObservable, factor::Number)::Nothing
    qk_obs_multiply_inplace(obs.ptr, to_qk_complex64(factor))
    nothing
end

function qk_obs_compose(first::SparseObservable, second::SparseObservable)::SparseObservable
    SparseObservable(qk_obs_compose(first.ptr, second.ptr))
end

function qk_obs_compose_map(first::SparseObservable, second::SparseObservable, qargs::AbstractVector{<:Integer})::SparseObservable
    SparseObservable(qk_obs_compose_map(first.ptr, second.ptr, qargs))
end

function qk_obs_apply_layout(obs::SparseObservable, layout::AbstractVector{<:Integer}, num_qubits::Integer)::Nothing
    qk_obs_apply_layout(obs.ptr, layout, num_qubits)
    nothing
end

function qk_obs_canonicalize(obs::SparseObservable, tol::Real)::SparseObservable
    SparseObservable(qk_obs_canonicalize(obs.ptr, tol))
end

function qk_obs_equal(obs::SparseObservable, other::SparseObservable)::Bool
    qk_obs_equal(obs.ptr, other.ptr)
end

function qk_obs_coeffs(obs::SparseObservable)
    qk_obs_coeffs(obs.ptr)
end

function qk_obs_indices(obs::SparseObservable)
    qk_obs_indices(obs.ptr)
end

function qk_obs_bit_terms(obs::SparseObservable)
    qk_obs_bit_terms(obs.ptr)
end

function qk_obs_boundaries(obs::SparseObservable)
    qk_obs_boundaries(obs.ptr)
end

function qk_obs_term(obs::SparseObservable, index::Integer)::QkObsTerm
    qk_obs_term(obs.ptr, index)
end

function qk_obs_str(obs::SparseObservable)::String
    qk_obs_str(obs.ptr)
end

function Base.copy(obs::SparseObservable)::SparseObservable
    qk_obs_copy(obs)
end

function Base.:(==)(obs::SparseObservable, other::SparseObservable)::Bool
    qk_obs_equal(obs, other)
end

function Base.string(obs::SparseObservable)::String
    qk_obs_str(obs)
end

function Base.show(io::IO, obs::SparseObservable)
    print(io, qk_obs_str(obs))
end

function Base.propertynames(obj::SparseObservable; private::Bool = false)
    union(fieldnames(typeof(obj)), (:num_terms, :num_qubits, :len, :coeffs, :bit_terms, :indices, :boundaries))
end

function Base.getproperty(obj::SparseObservable, sym::Symbol)
    if sym === :num_terms
        return qk_obs_num_terms(obj)
    elseif sym === :num_qubits
        return qk_obs_num_qubits(obj)
    elseif sym === :len
        return qk_obs_len(obj)
    elseif sym === :coeffs
        return qk_obs_coeffs(obj)
    elseif sym === :bit_terms
        return qk_obs_bit_terms(obj)
    elseif sym === :indices
        return qk_obs_indices(obj)
    elseif sym === :boundaries
        return qk_obs_boundaries(obj)
    else
        return getfield(obj, sym)
    end
end

export SparseObservable
