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

obs = SparseObservable(5)
@test qk_obs_num_terms(obs) == 0
@test qk_obs_num_qubits(obs) == 5

bits = QkBitTerm[QkBitTerm_X, QkBitTerm_Y]
indices = UInt32[0, 1]
term = QkObsTerm(QkComplex64(1.0, 0.0), 2, pointer(bits), pointer(indices), 5)
qk_obs_add_term(obs, term)

@test qk_obs_num_terms(obs) == 1
@test qk_obs_len(obs) == 2
@test qk_obs_str(obs) == string(obs)
@test copy(obs) == obs

view = qk_obs_term(obs, 0)
@test view.len == 2
@test view.num_qubits == 5
@test unsafe_load(qk_obs_coeffs(obs), 1).re == 1.0
@test unsafe_load(qk_obs_bit_terms(obs), 1) == QkBitTerm_X
@test unsafe_load(qk_obs_indices(obs), 1) == 0
@test unsafe_load(qk_obs_boundaries(obs), 1) == 0
@test unsafe_load(qk_obs_boundaries(obs), 2) == 2

@testset "BitTerm labels" begin
    @test qk_bitterm_label(QkBitTerm_X) == 'X'
    @test qk_bitterm_label(QkBitTerm_Y) == 'Y'
    @test qk_bitterm_label(QkBitTerm_Z) == 'Z'
    @test qk_bitterm_label(QkBitTerm_Plus) == '+'
    @test qk_bitterm_label(QkBitTerm_Minus) == '-'
    @test qk_bitterm_label(QkBitTerm_Right) == 'r'
    @test qk_bitterm_label(QkBitTerm_Left) == 'l'
    @test qk_bitterm_label(QkBitTerm_Zero) == '0'
    @test qk_bitterm_label(QkBitTerm_One) == '1'
end
