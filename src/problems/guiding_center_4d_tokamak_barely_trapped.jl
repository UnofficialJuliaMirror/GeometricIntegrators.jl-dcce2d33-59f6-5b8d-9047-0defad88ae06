module GuidingCenter4dTokamakBarelyTrapped

    export guiding_center_4d_ode, guiding_center_4d_iode,
           hamiltonian, toroidal_momentum, α1, α2, α3, α4

    const μ  = 2.250E-6
    const q₀ = [1.05, 0., 0., 7.610E-04]

    include("magnetic_field_tokamak.jl")
    include("guiding_center_4d.jl")

end
