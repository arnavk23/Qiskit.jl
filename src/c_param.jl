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

import .LibQiskit: QkParam, QkComplex64

mutable struct Parameter
    ptr::Ptr{QkParam}
    function Parameter(ptr::Ptr{QkParam})
        check_not_null(ptr)
        param = new(ptr)
        finalizer(qk_param_free, param)
        param
    end
end

function check_not_null(param::Ptr{QkParam})::Nothing
    if param == C_NULL
        throw(ArgumentError("Ptr{QkParam} is NULL."))
    end
    nothing
end

function Parameter()::Parameter
    Parameter(LibQiskit.qk_param_zero())
end

function Parameter(name::AbstractString)::Parameter
    isempty(name) && throw(ArgumentError("Parameter symbol name cannot be empty."))
    Parameter(LibQiskit.qk_param_new_symbol(name))
end

function Parameter(value::Real)::Parameter
    Parameter(LibQiskit.qk_param_from_double(Float64(value)))
end

function Parameter(value::Complex)::Parameter
    Parameter(LibQiskit.qk_param_from_complex(LibQiskit.QkComplex64(real(value), imag(value))))
end

function qk_param_free(param::Parameter)::Nothing
    if param.ptr != C_NULL
        LibQiskit.qk_param_free(param.ptr)
        param.ptr = C_NULL
    end
    nothing
end

function Base.copy(param::Parameter)::Parameter
    check_not_null(param.ptr)
    Parameter(LibQiskit.qk_param_copy(param.ptr))
end

function _param_string(param::Parameter)::String
    check_not_null(param.ptr)
    str = LibQiskit.qk_param_str(param.ptr)
    try
        return unsafe_string(str)
    finally
        LibQiskit.qk_str_free(str)
    end
end

Base.string(param::Parameter) = _param_string(param)
Base.convert(::Type{Float64}, param::Parameter) = LibQiskit.qk_param_as_real(param.ptr)
Base.float(param::Parameter) = Float64(param)

function Base.hash(param::Parameter, h::UInt)
    hash(_param_string(param), h)
end

function Base.:(==)(lhs::Parameter, rhs::Parameter)
    check_not_null(lhs.ptr)
    check_not_null(rhs.ptr)
    LibQiskit.qk_param_equal(lhs.ptr, rhs.ptr)
end

Base.:(==)(lhs::Parameter, rhs::Number) = lhs == Parameter(rhs)
Base.:(==)(lhs::Number, rhs::Parameter) = Parameter(lhs) == rhs
Base.isequal(lhs::Parameter, rhs::Parameter) = lhs == rhs
Base.isequal(lhs::Parameter, rhs::Number) = lhs == rhs
Base.isequal(lhs::Number, rhs::Parameter) = lhs == rhs

_parameter(x::Parameter) = x
_parameter(x::Number) = Parameter(x)

function _binary_param(op, lhs, rhs)
    lhs_param = _parameter(lhs)
    rhs_param = _parameter(rhs)
    out = Parameter()
    check_exit_code(op(out.ptr, lhs_param.ptr, rhs_param.ptr))
    return out
end

function _unary_param(op, src)
    src_param = _parameter(src)
    out = Parameter()
    check_exit_code(op(out.ptr, src_param.ptr))
    return out
end

function Base.:+(lhs::Parameter, rhs::Parameter)
    _binary_param(LibQiskit.qk_param_add, lhs, rhs)
end

function Base.:+(lhs::Parameter, rhs::Number)
    _binary_param(LibQiskit.qk_param_add, lhs, rhs)
end

function Base.:+(lhs::Number, rhs::Parameter)
    _binary_param(LibQiskit.qk_param_add, lhs, rhs)
end

function Base.:-(lhs::Parameter, rhs::Parameter)
    _binary_param(LibQiskit.qk_param_sub, lhs, rhs)
end

function Base.:-(lhs::Parameter, rhs::Number)
    _binary_param(LibQiskit.qk_param_sub, lhs, rhs)
end

function Base.:-(lhs::Number, rhs::Parameter)
    _binary_param(LibQiskit.qk_param_sub, lhs, rhs)
end

function Base.:*(lhs::Parameter, rhs::Parameter)
    _binary_param(LibQiskit.qk_param_mul, lhs, rhs)
end

function Base.:*(lhs::Parameter, rhs::Number)
    _binary_param(LibQiskit.qk_param_mul, lhs, rhs)
end

function Base.:*(lhs::Number, rhs::Parameter)
    _binary_param(LibQiskit.qk_param_mul, lhs, rhs)
end

function Base.:/(lhs::Parameter, rhs::Parameter)
    _binary_param(LibQiskit.qk_param_div, lhs, rhs)
end

function Base.:/(lhs::Parameter, rhs::Number)
    _binary_param(LibQiskit.qk_param_div, lhs, rhs)
end

function Base.:/(lhs::Number, rhs::Parameter)
    _binary_param(LibQiskit.qk_param_div, lhs, rhs)
end

function Base.:^(lhs::Parameter, rhs::Parameter)
    _binary_param(LibQiskit.qk_param_pow, lhs, rhs)
end

function Base.:^(lhs::Parameter, rhs::Number)
    _binary_param(LibQiskit.qk_param_pow, lhs, rhs)
end

function Base.:^(lhs::Number, rhs::Parameter)
    _binary_param(LibQiskit.qk_param_pow, lhs, rhs)
end

function Base.:-(src::Parameter)
    _unary_param(LibQiskit.qk_param_neg, src)
end

function Base.sin(src::Parameter)
    _unary_param(LibQiskit.qk_param_sin, src)
end

function Base.cos(src::Parameter)
    _unary_param(LibQiskit.qk_param_cos, src)
end

function Base.tan(src::Parameter)
    _unary_param(LibQiskit.qk_param_tan, src)
end

function Base.asin(src::Parameter)
    _unary_param(LibQiskit.qk_param_asin, src)
end

function Base.acos(src::Parameter)
    _unary_param(LibQiskit.qk_param_acos, src)
end

function Base.atan(src::Parameter)
    _unary_param(LibQiskit.qk_param_atan, src)
end

function Base.log(src::Parameter)
    _unary_param(LibQiskit.qk_param_log, src)
end

function Base.exp(src::Parameter)
    _unary_param(LibQiskit.qk_param_exp, src)
end

function Base.abs(src::Parameter)
    _unary_param(LibQiskit.qk_param_abs, src)
end

function Base.sign(src::Parameter)
    _unary_param(LibQiskit.qk_param_sign, src)
end

function Base.conj(src::Parameter)
    _unary_param(LibQiskit.qk_param_conjugate, src)
end

function Base.show(io::IO, param::Parameter)
    if param.ptr == C_NULL
        print(io, "Parameter(NULL)")
    else
        print(io, "Parameter(", _param_string(param), ")")
    end
end

function Base.show(io::IO, ::MIME"text/plain", param::Parameter)
    if param.ptr == C_NULL
        print(io, "Parameter(NULL)")
    else
        print(io, "Parameter\n  value: ", _param_string(param))
    end
end

export Parameter
