using DifferentialEquations
using Plots

# Начальные условия
x0 = 321000.0   # начальная численность армии X
y0 = 123000.0   # начальная численность армии Y
tspan = (0.0, 10.0)  # время моделирования (10 дней)

# ================== МОДЕЛЬ 1 ==================
# Регулярные войска
function model1!(du, u, p, t)
    x, y = u
    a, b, c, h = p
    du[1] = -a*x - b*y + sin(t+1) + 1
    du[2] = -c*x - h*y + cos(t+2) + 1
end

p1 = [0.336, 0.877, 0.441, 0.232]  # a, b, c, h
u0 = [x0, y0]
prob1 = ODEProblem(model1!, u0, tspan, p1)
sol1 = solve(prob1, saveat=0.1)

# Победитель в модели 1
if sol1.u[end][1] <= 0 && sol1.u[end][2] > 0
    winner1 = "Y (армия Y победила)"
elseif sol1.u[end][2] <= 0 && sol1.u[end][1] > 0
    winner1 = "X (армия X победила)"
elseif sol1.u[end][1] <= 0 && sol1.u[end][2] <= 0
    winner1 = "Обе армии уничтожены"
else
    winner1 = "Ничья (обе ещё сражаются)"
end

# ================== МОДЕЛЬ 2 ==================
# Регулярные vs Партизаны
function model2!(du, u, p, t)
    x, y = u
    a, b, c, h = p
    du[1] = -a*x - b*y + sin(2t) + 2
    du[2] = -c*x*y - h*y + cos(t) + 2
end

p2 = [0.432, 0.815, 0.336, 0.245]  # a, b, c, h
prob2 = ODEProblem(model2!, u0, tspan, p2)
sol2 = solve(prob2, saveat=0.1)

eps = 1e-3

x_end = sol2.u[end][1]
y_end = sol2.u[end][2]

if x_end <= eps && y_end > eps
    winner2 = "Y (армия Y победила)"
elseif y_end <= eps && x_end > eps
    winner2 = "X (армия X победила)"
elseif x_end <= eps && y_end <= eps
    winner2 = "Обе армии уничтожены"
else
    winner2 = "Ничья (обе ещё сражаются)"
end
# ================== ГРАФИКИ ==================
# Используем idxs 
p1 = plot(sol1, idxs=[1,2], 
          label=["X(t) - регулярные" "Y(t) - регулярные"], 
          title="Модель 1: регулярные войска\nПобедитель: $winner1",
          xlabel="Время (дни)", ylabel="Численность (чел)",
          linewidth=2, legend=:topright)

p2 = plot(sol2, idxs=[1,2], 
          label=["X(t) - регулярные" "Y(t) - партизаны"], 
          title="Модель 2: регулярные vs партизаны\nПобедитель: $winner2",
          xlabel="Время (дни)", ylabel="Численность (чел)",
          linewidth=2, legend=:topright)

# Объединяем графики
plot(p1, p2, layout=(2,1), size=(800,600))
savefig("combined_plots.png")

x1_end = sol1.u[end][1]
y1_end = sol1.u[end][2]

x2_end = sol2.u[end][1]
y2_end = sol2.u[end][2]

println("Модель 1:")
println("X = ", x1_end)
println("Y = ", y1_end)

println("\nМодель 2:")
println("X = ", x2_end)
println("Y = ", y2_end)
