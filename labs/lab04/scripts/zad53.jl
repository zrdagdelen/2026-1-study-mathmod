using DifferentialEquations
using Plots

# начальные условия
u0 = [1.9, 0.9]   # [x, x']
tspan = (0.0, 49.0)
t = 0:0.05:49

##################################################
# 1. Без затухания
# x'' + 1.9x = 0
##################################################

function osc1!(du, u, p, t)
    du[1] = u[2]
    du[2] = -1.9 * u[1]
end

prob1 = ODEProblem(osc1!, u0, tspan)
sol1 = solve(prob1, saveat=t)

p1 = plot(sol1.t, sol1[1,:], title="1. Без затухания", label="x(t)")
p2 = plot(sol1[1,:], sol1[2,:], xlabel="x", ylabel="x'", title="Фазовый портрет")

##################################################
# 2. С затуханием
# x'' + 2.9x' + 3.9x = 0
##################################################

function osc2!(du, u, p, t)
    du[1] = u[2]
    du[2] = -3.9 * u[1] - 2.9 * u[2]
end

prob2 = ODEProblem(osc2!, u0, tspan)
sol2 = solve(prob2, saveat=t)

p3 = plot(sol2.t, sol2[1,:], title="2. С затуханием", label="x(t)")
p4 = plot(sol2[1,:], sol2[2,:], xlabel="x", ylabel="x'", title="Фазовый портрет")

##################################################
# 3. С затуханием и внешней силой
# x'' + 4.9x' + 5.9x = 6.9 sin(7.9t)
##################################################

function osc3!(du, u, p, t)
    du[1] = u[2]
    du[2] = -5.9 * u[1] - 4.9 * u[2] + 6.9*sin(7.9*t)
end

prob3 = ODEProblem(osc3!, u0, tspan)
sol3 = solve(prob3, saveat=t)

p5 = plot(sol3.t, sol3[1,:], title="3. С внешней силой", label="x(t)")
p6 = plot(sol3[1,:], sol3[2,:], xlabel="x", ylabel="x'", title="Фазовый портрет")

##################################################
# вывод 
##################################################
savefig(p1, "osc1_time.png")
savefig(p2, "osc1_phase.png")
savefig(p3, "osc2_time.png")
savefig(p4, "osc2_phase.png")
savefig(p5, "osc3_time.png")
savefig(p6, "osc3_phase.png")

p_all = plot(p1, p2, p3, p4, p5, p6, layout=(3,2))
savefig(p_all, "all_plots.png")
