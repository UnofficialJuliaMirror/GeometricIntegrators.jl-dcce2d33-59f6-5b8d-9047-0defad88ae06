
abstract type SolutionPDAE{dType, tType, N} <: Solution{dType, tType, N} end


"Serial Solution of a partitioned differential algebraic equation."
struct SSolutionPDAE{dType, tType, N} <: SolutionPDAE{dType, tType, N}
    nd::Int
    nm::Int
    nt::Int
    ni::Int
    t::TimeSeries{tType}
    q::SDataSeries{dType,N}
    p::SDataSeries{dType,N}
    λ::SDataSeries{dType,N}
    ntime::Int
    nsave::Int
end

function SSolutionPDAE(equation::Union{IODE{DT,TT},PDAE{DT,TT},IDAE{DT,TT}}, Δt::TT, ntime::Int, nsave::Int=1) where {DT,TT}
    N  = equation.n > 1 ? 3 : 2
    nd = equation.d
    nm = equation.m
    ni = equation.n
    nt = div(ntime, nsave)

    @assert DT <: Number
    @assert TT <: Real
    @assert nd > 0
    @assert nm > 0
    @assert ni > 0
    @assert nsave > 0
    @assert ntime ≥ nsave
    @assert mod(ntime, nsave) == 0

    t = TimeSeries{TT}(nt, Δt, nsave)
    q = SDataSeries(DT, nd, nt, ni)
    p = SDataSeries(DT, nd, nt, ni)
    λ = SDataSeries(DT, nm, nt, ni)
    s = SSolutionPDAE{DT,TT,N}(nd, nm, nt, ni, t, q, p, λ, ntime, nsave)
    set_initial_conditions!(s, equation)
    return s
end


"Parallel Solution of a partitioned differential algebraic equation."
struct PSolutionPDAE{dType, tType, N} <: SolutionPDAE{dType, tType, N}
    nd::Int
    nm::Int
    nt::Int
    ni::Int
    t::TimeSeries{tType}
    q::PDataSeries{dType,N}
    p::PDataSeries{dType,N}
    λ::PDataSeries{dType,N}
    ntime::Int
    nsave::Int
end

function PSolutionPDAE(equation::Union{IODE{DT,TT},PDAE{DT,TT},IDAE{DT,TT}}, Δt::TT, ntime::Int, nsave::Int=1) where {DT,TT}
    N  = equation.n > 1 ? 3 : 2
    nd = equation.d
    nm = equation.m
    ni = equation.n
    nt = div(ntime, nsave)

    @assert DT <: Number
    @assert TT <: Real
    @assert nd > 0
    @assert nm > 0
    @assert ni > 0
    @assert nsave > 0
    @assert ntime ≥ nsave
    @assert mod(ntime, nsave) == 0

    t = TimeSeries{TT}(nt, Δt, nsave)
    q = PDataSeries(DT, nd, nt, ni)
    p = PDataSeries(DT, nd, nt, ni)
    λ = PDataSeries(DT, nm, nt, ni)
    s = PSolutionPDAE{DT,TT,N}(nd, nm, nt, ni, t, q, p, λ, ntime, nsave)
    set_initial_conditions!(s, equation)
    return s
end


function set_initial_conditions!(sol::SolutionPDAE{DT,TT}, equ::Union{PDAE{DT,TT},IDAE{DT,TT}}) where {DT,TT}
    set_initial_conditions!(sol, equ.t₀, equ.q₀, equ.p₀, equ.λ₀)
end

function set_initial_conditions!(sol::SolutionPDAE{DT,TT}, equ::IODE{DT,TT}) where {DT,TT}
    set_initial_conditions!(sol, equ.t₀, equ.q₀, equ.p₀, zeros(equ.q₀))
end

function set_initial_conditions!(sol::SolutionPDAE{DT,TT}, t₀::TT, q₀::Array{DT}, p₀::Array{DT}, λ₀::Array{DT}) where {DT,TT}
    set_data!(sol.q, q₀, 0)
    set_data!(sol.p, p₀, 0)
    set_data!(sol.λ, λ₀, 0)
    compute_timeseries!(sol.t, t₀)
end

function get_initial_conditions!(sol::SolutionPDAE{DT,TT}, q::Vector{DT}, p::Vector{DT}, λ::Vector{DT}, k) where {DT,TT}
    get_data!(sol.q, q, 0, k)
    get_data!(sol.p, p, 0, k)
    get_data!(sol.λ, λ, 0, k)
end

function get_initial_conditions!(sol::SolutionPDAE{DT,TT}, q::Vector{DT}, p::Vector{DT}, k) where {DT,TT}
    get_data!(sol.q, q, 0, k)
    get_data!(sol.p, p, 0, k)
end

function copy_solution!(sol::SolutionPDAE{DT,TT}, q::Vector{DT}, p::Vector{DT}, λ::Vector{DT}, n, k) where {DT,TT}
    if mod(n, sol.nsave) == 0
        j = div(n, sol.nsave)
        set_data!(sol.q, q, j, k)
        set_data!(sol.p, p, j, k)
        set_data!(sol.λ, λ, j, k)
    end
end

function copy_solution!(sol::SolutionPDAE{DT,TT}, q::Vector{DT}, p::Vector{DT}, n, k) where {DT,TT}
    if mod(n, sol.nsave) == 0
        j = div(n, sol.nsave)
        set_data!(sol.q, q, j, k)
        set_data!(sol.p, p, j, k)
    end
end

function reset!(s::SolutionPDAE)
    reset!(s.q)
    reset!(s.p)
    reset!(s.λ)
    compute_timeseries!(solution.t, solution.t[end])
end
