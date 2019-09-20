module IntegratorsTest

    export test_integrators

    using GeometricIntegrators
    using Test

    set_config(:nls_solver, NewtonSolver)
    set_config(:jacobian_autodiff, false)

    using ..OscillatorTest
    using ..OscillatorTest: Δt, nt, refx, refq, refp

    include("utils.jl")

    ode  = oscillator_ode()
    pode = oscillator_pode()
    sode = oscillator_sode()
    iode = oscillator_iode()
    idae = oscillator_idae()
    pdae = oscillator_pdae()


    function test_integrators()

        @test typeof(Integrator(ode, getTableauExplicitMidpoint(), Δt)) <: IntegratorERK
        @test typeof(Integrator(ode, getTableauCrouzeix(), Δt)) <: IntegratorDIRK
        @test typeof(Integrator(ode, getTableauImplicitMidpoint(), Δt)) <: IntegratorFIRK


        ### ERK Integrators ###

        int = Integrator(ode, getTableauExplicitEuler(), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 5E-2

        int = Integrator(ode, getTableauExplicitMidpoint(), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 1E-3

        int = Integrator(ode, getTableauERK4(), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 5E-7

        ### IRK Integrators ###

        int = Integrator(ode, getTableauCrouzeix(), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 5E-5

        int = Integrator(ode, getTableauImplicitEuler(), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 5E-2

        int = Integrator(ode, getTableauImplicitMidpoint(), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 5E-4

        int = IntegratorFIRK(ode, getTableauGLRK(1), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 5E-4

        int = IntegratorFIRK(ode, getTableauGLRK(2), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 1E-7

        int = IntegratorFIRK(ode, getTableauGLRK(3), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 1E-11

        int = IntegratorFIRK(ode, getTableauGLRK(4), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 1E-15

        int = IntegratorFIRK(ode, getTableauGLRK(5), Δt)

        @test rel_err(sol.q, refx) < 1E-15

        int = IntegratorFIRK(ode, getTableauGLRK(6), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 1E-15

        int = IntegratorFIRK(ode, getTableauGLRK(7), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 5E-15

        int = IntegratorFIRK(ode, getTableauSRK3(), Δt)
        sol = integrate(int, nt)

        @test rel_err(sol.q, refx) < 1E-7

        ### PRK Integrators ###

        pint = Integrator(pode, getTableauSymplecticEulerA(), Δt)
        psol = integrate(pint, nt)

        @test rel_err(psol.q, refq) < 5E-2
        @test rel_err(psol.p, refp) < 1E-3

        pint = Integrator(pode, getTableauSymplecticEulerB(), Δt)
        psol = integrate(pint, nt)

        @test rel_err(psol.q, refq) < 5E-2
        @test rel_err(psol.p, refp) < 1E-3

        pint = Integrator(pode, TableauEPRK(:prk4, 4, getTableauERK4().q), Δt)
        psol = integrate(pint, nt)

        @test rel_err(psol.q, refq) < 5E-7
        @test rel_err(psol.p, refp) < 5E-7

        pint = Integrator(pode, TableauIPRK(:pglrk, 2, getCoefficientsGLRK(1)), Δt)
        psol = integrate(pint, nt)

        @test rel_err(psol.q, refq) < 5E-4
        @test rel_err(psol.p, refp) < 5E-4

        pint = Integrator(pode, TableauIPRK(:pglrk, 4, getCoefficientsGLRK(2)), Δt)
        psol = integrate(pint, nt)

        @test rel_err(psol.q, refq) < 1E-7
        @test rel_err(psol.p, refp) < 1E-7

        pint = Integrator(pode, TableauIPRK(:pglrk, 6, getCoefficientsGLRK(3)), Δt)
        psol = integrate(pint, nt)

        @test rel_err(psol.q, refq) < 1E-11
        @test rel_err(psol.p, refp) < 1E-11


        ### Special Integrators ###

        pgint = IntegratorPGLRK(iode, getCoefficientsPGLRK(2), Δt)
        pgsol = integrate(pgint, nt)

        @test rel_err(pgsol.q, refx) < 1E-5


        ### CGVI and DGVI Integrators ###

        QGau4 = GaussLegendreQuadrature(4)
        BGau4 = LagrangeBasis(nodes(QGau4))

        cgint = IntegratorCGVI(iode, BGau4, QGau4, Δt)
        cgsol = integrate(cgint, nt)

        @test rel_err(cgsol.q, refx) < 1E-7

        dgint = IntegratorDGVI(iode, BGau4, QGau4, Δt)
        dgsol = integrate(dgint, nt)

        @test rel_err(dgsol.q, refx) < 1E-7


        ### Splitting Integrators ###

        sint = Integrator(sode, getTableauLieA(), Δt)
        ssol = integrate(sint, nt)

        @test rel_err(ssol.q, refx) < 5E-2

        sint = Integrator(sode, getTableauLieB(), Δt)
        ssol = integrate(sint, nt)

        @test rel_err(ssol.q, refx) < 5E-2

        sint = Integrator(sode, getTableauStrang(), Δt)
        ssol = integrate(sint, nt)

        @test rel_err(ssol.q, refx) < 1E-3

        sint = Integrator(sode, getTableauMcLachlan2(), Δt)
        ssol = integrate(sint, nt)

        @test rel_err(ssol.q, refx) < 1E-4

        sint = Integrator(sode, getTableauMcLachlan4(), Δt)
        ssol = integrate(sint, nt)

        @test rel_err(ssol.q, refx) < 5E-4

        sint = Integrator(sode, getTableauTripleJump(), Δt)
        ssol = integrate(sint, nt)

        @test rel_err(ssol.q, refx) < 5E-6

        sint = Integrator(sode, getTableauSuzukiFractal(), Δt)
        ssol = integrate(sint, nt)

        @test rel_err(ssol.q, refx) < 5E-7
    end
end

using .IntegratorsTest
test_integrators()
