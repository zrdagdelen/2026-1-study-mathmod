using DrWatson
@quickactivate "project"
using DifferentialEquations, Plots

# Параметры модели (вариант 53)
# Используем нормированную форму SIR: dS/dt = -(α/N)*S*I
# Тогда I* = β*N/α
N = 6159   # общая численность из задания

# Подбираем α и β так, чтобы I* было около 200 (между 173 и 300)
# I* = β*N/α  =>  при α=0.01, β=0.000325 => I* ≈ 200
α = 0.01
β = 0.000325

I_crit = β * N / α  # ≈ 200 — порог эпидемии

# Начальные условия из задания
I0 = 173
R0 = 61
S0 = N - I0 - R0  # = 5925

println("\n" * "="^60)
println("МОДЕЛЬ ЭПИДЕМИИ (SIR)")
println("="^60)
println("Параметры:")
println("α (коэффициент заболеваемости) = $α")
println("β (коэффициент выздоровления)  = $β")
println("N (общая численность)           = $N")
println("I* = β·N/α = $(round(I_crit, digits=1))")
println("\nНачальные условия (из задания):")
println("S(0) = $S0")
println("I(0) = $I0")
println("R(0) = $R0")
println("="^60)

# ============================================================
# СЛУЧАЙ 1: I(0) <= I* — эпидемии нет, больные изолированы
# S не меняется, инфицированные только выздоравливают
# Используем I0 = 173 < I* ≈ 200 ✅
# ============================================================
function epidemic_case1!(du, u, p, t)
    S, I, R = u
    du[1] = 0.0
    du[2] = -β * I
    du[3] =  β * I
end

u0_case1 = [float(S0), float(I0), float(R0)]
tspan = (0.0, 2000.0)

prob1 = ODEProblem(epidemic_case1!, u0_case1, tspan)
sol1  = solve(prob1, Tsit5(), saveat=1.0)

# ============================================================
# СЛУЧАЙ 2: I(0) > I* — эпидемия распространяется
# Берём I0_case2 = 300 > I* ≈ 200 ✅
# ============================================================
function epidemic_case2!(du, u, p, t)
    S, I, R = u
    du[1] = -(α / N) * S * I           # нормированная форма
    du[2] =  (α / N) * S * I - β * I
    du[3] =  β * I
end

I0_case2 = 300
S0_case2 = N - I0_case2 - R0
u0_case2 = [float(S0_case2), float(I0_case2), float(R0)]

prob2 = ODEProblem(epidemic_case2!, u0_case2, tspan)
sol2  = solve(prob2, Tsit5(), saveat=1.0)

# ============================================================
# Построение графиков
# ============================================================
p1 = plot(sol1,
    label     = ["S(t) восприимчивые" "I(t) инфицированные" "R(t) с иммунитетом"],
    title     = "Случай 1: I(0) = $I0 ≤ I* ≈ $(round(Int, I_crit)) (эпидемии нет)",
    xlabel    = "Время (дни)", ylabel = "Численность",
    linewidth = 2, legend = :right)

p2 = plot(sol2,
    label     = ["S(t) восприимчивые" "I(t) инфицированные" "R(t) с иммунитетом"],
    title     = "Случай 2: I(0) = $I0_case2 > I* ≈ $(round(Int, I_crit)) (эпидемия)",
    xlabel    = "Время (дни)", ylabel = "Численность",
    linewidth = 2, legend = :right)

combined = plot(p1, p2, layout=(2,1), size=(800, 1000))
savefig(combined, "epidemic_results.png")
display(combined)

println("\n✅ График сохранён в epidemic_results.png")

# ============================================================
# Анализ результатов
# ============================================================
println("\n" * "="^60)
println("АНАЛИЗ РЕЗУЛЬТАТОВ")
println("="^60)

S_end1, I_end1, R_end1 = sol1[end]
println("\nСлучай 1 (I(0) ≤ I*):")
println("  S = $(round(S_end1, digits=1))")
println("  I = $(round(I_end1, digits=1))")
println("  R = $(round(R_end1, digits=1))")

S_end2, I_end2, R_end2 = sol2[end]
println("\nСлучай 2 (I(0) > I*):")
println("  S = $(round(S_end2, digits=1))")
println("  I = $(round(I_end2, digits=1))")
println("  R = $(round(R_end2, digits=1))")

I_max = maximum(sol2[2, :])
t_max = sol2.t[argmax(sol2[2, :])]
println("\n  Пик эпидемии:")
println("  Максимальное число инфицированных: $(round(I_max, digits=1))")
println("  Время достижения пика: $(round(t_max, digits=1)) дней")

println("\n✅ Анализ завершён")


using DelimitedFiles
mkpath("results")

results = [
    "Параметр α"             α
    "Параметр β"             β
    "Общая численность N"    N
    "Критическое значение I*" I_crit
    "Начальные S0 (случай 2)" S0
    "Начальные I0 (случай 2)" I0
    "Начальные R0"           R0
    "Случай 1: S кон."       round(S_end1, digits=1)
    "Случай 1: I кон."       round(I_end1, digits=1)
    "Случай 1: R кон."       round(R_end1, digits=1)
    "Случай 2: S кон."       round(S_end2, digits=1)
    "Случай 2: I кон."       round(I_end2, digits=1)
    "Случай 2: R кон."       round(R_end2, digits=1)
    "Пик эпидемии (I_max)"   round(I_max, digits=1)
    "Время пика (t_max)"     round(t_max, digits=1)
]

writedlm("results/results.csv", results, ',')
cp("epidemic_results.png", "results/epidemic_results.png", force=true)
println("\n✅ Результаты сохранены в results/")
