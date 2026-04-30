module QiskitUnitfulExt

import Unitful
import Qiskit: DelayInstructionClosure
import Qiskit.C: qk_circuit_delay, QkDelayUnit_S, QkDelayUnit_MS, QkDelayUnit_US, QkDelayUnit_NS, QkDelayUnit_PS

"""
    (cl::DelayInstructionClosure)(qubit::Integer, duration::Unitful.Quantity)::Nothing

Method for Unitful quantities. Preserves the user's chosen unit when possible.

# Arguments
- `qubit`: The qubit index
- `duration`: A Unitful.jl quantity (e.g., `1.0u"μs"`)

The method extracts the numeric value and unit specified by the user. If the unit 
directly maps to a Qiskit delay unit (s, ms, μs, ns, ps), it is used as-is. 
Otherwise, the quantity is converted to seconds and the most appropriate unit is selected.
"""
function (cl::DelayInstructionClosure)(qubit::Integer, duration::Unitful.Quantity)::Nothing
    # Extract the numeric value and unit the user specified
    val = Unitful.ustrip(duration)
    u = Unitful.unit(duration)
    
    # Try to map directly to a Qiskit-supported unit
    if u == Unitful.s
        qk_unit = QkDelayUnit_S
        final_duration = val
    elseif u == Unitful.ms
        qk_unit = QkDelayUnit_MS
        final_duration = val
    elseif u == Unitful.μs
        qk_unit = QkDelayUnit_US
        final_duration = val
    elseif u == Unitful.ns
        qk_unit = QkDelayUnit_NS
        final_duration = val
    elseif u == Unitful.ps
        qk_unit = QkDelayUnit_PS
        final_duration = val
    else
        # If the unit doesn't exactly match, convert to seconds and choose the best unit
        duration_s = Unitful.uconvert(Unitful.s, duration) |> Unitful.ustrip
        
        if duration_s >= 1
            qk_unit = QkDelayUnit_S
            final_duration = duration_s
        elseif duration_s >= 1e-3
            qk_unit = QkDelayUnit_MS
            final_duration = duration_s * 1e3
        elseif duration_s >= 1e-6
            qk_unit = QkDelayUnit_US
            final_duration = duration_s * 1e6
        elseif duration_s >= 1e-9
            qk_unit = QkDelayUnit_NS
            final_duration = duration_s * 1e9
        else
            qk_unit = QkDelayUnit_PS
            final_duration = duration_s * 1e12
        end
    end
    
    qk_circuit_delay(cl.qc, qubit, final_duration, qk_unit)
    return nothing
end

end
