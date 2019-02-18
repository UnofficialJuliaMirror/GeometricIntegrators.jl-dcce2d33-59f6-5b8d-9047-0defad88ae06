
"Holds the tableau of a diagonally implicit Runge-Kutta method."
struct TableauDIRK{T} <: AbstractTableauIRK{T}
    @HeaderTableau

    q::CoefficientsRK{T}

    function TableauDIRK{T}(q) where {T}
        @assert istril(q.a)
        @assert !(q.s==1 && q.a[1,1] ≠ 0)

        if q.s > 1 && istrilstrict(q.a)
            @warn "Initializing TableauDIRK with explicit tableau $(q.name).\nYou might want to use TableauERK instead."
        end

        new(q.name, q.o, q.s, q)
    end
end

function TableauDIRK(q::CoefficientsRK{T}) where {T}
    TableauDIRK{T}(q)
end

function TableauDIRK(name::Symbol, order::Int, a::Matrix{T}, b::Vector{T}, c::Vector{T}) where {T}
    TableauDIRK{T}(CoefficientsRK(name, order, a, b, c))
end

# TODO function readTableauDIRKFromFile(dir::AbstractString, name::AbstractString)


"Diagonally implicit Runge-Kutta integrator."
struct IntegratorDIRK{DT,TT,FT} <: Integrator{DT,TT}
    equation::ODE{DT,TT,FT}
    tableau::TableauDIRK{TT}
    Δt::TT

    x::Vector{Vector{TwicePrecision{DT}}}
    X::Vector{Vector{DT}}
    Y::Vector{Vector{DT}}
    F::Vector{Vector{DT}}

    function IntegratorDIRK{DT,TT,FT}(equation, tableau, Δt) where {DT,TT,FT}
        D = equation.d
        M = equation.n
        S = tableau.q.s
        X = create_internal_stage_vector(DT, D, S)
        Y = create_internal_stage_vector(DT, D, S)
        F = create_internal_stage_vector(DT, D, S)
        new(equation, tableau, Δt, create_solution_vector(DT,D,M), X, Y, F)
    end
end

function IntegratorDIRK(equation::Equation, tableau::TableauDIRK, Δt)
    DT = eltype(equation.q₀)
    TT = typeof(Δt)
    FT = typeof(equation.v)
    IntegratorDIRK{DT,TT,FT}(equation, tableau, Δt)
end

"Integrate ODE with diagonally implicit Runge-Kutta integrator."
function integrate!(int::IntegratorDIRK, s::SolutionODE)
    # TODO
end

"Integrate partitioned ODE with diagonally implicit Runge-Kutta integrator."
function integrate!(int::IntegratorDIRK, s::SolutionPODE)
    # TODO
end
