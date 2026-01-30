using Plots #, LaTeXStrings

# Параметры симуляции
L = 1.0          # длина струны
N = 200          # число точек
c = 1.0          # скорость волны
T = 4.0          # общее время
dx = L / (N-1)
dt = 0.4 * dx / c  # условие устойчивости: σ = c·dt/dx ≤ 1
σ² = (c * dt / dx)^2
steps = round(Int, T / dt)

# Краевые условия: :dirichlet (u=0) или :neumann (uₓ=0)
bc_left = :dirichlet
bc_right = :dirichlet  # поменяй на :neumann чтобы увидеть разницу!

# Инициализация
u = zeros(N)
u_prev = zeros(N)
u_next = zeros(N)

# Начальное условие: "горб" в центре
x = range(0, L, length=N)
u .=  @. exp(-50 * (x - 0.3)^2)  # импульс слева от центра
u_prev .= u .- dt * 0.0  # начальная скорость = 0

# Функция применения краевых условий
function apply_bc!(u, bc_left, bc_right)
    if bc_left == :dirichlet
        u[1] = 0.0
    elseif bc_left == :neumann
        u[1] = u[2]  # ∂u/∂x ≈ (u₂-u₁)/dx = 0 ⇒ u₁ = u₂
    end
    
    if bc_right == :dirichlet
        u[end] = 0.0
    elseif bc_right == :neumann
        u[end] = u[end-1]
    end
end

# Симуляция + визуализация
anim = @animate for n in 1:steps
    global u, u_prev, u_next;
    # Явная схема второго порядка (центральные разности)
    for i in 2:N-1
        u_next[i] = 2u[i] - u_prev[i] + σ² * (u[i+1] - 2u[i] + u[i-1])
    end
    
    apply_bc!(u_next, bc_left, bc_right)
    
    # Обновление состояния
    u_prev, u = u, u_next
    
    # Визуализация
    plot(x, u, 
         ylims=(-1.2, 1.2), 
         xlabel="x", ylabel="u(x,t)",
         title="t = $(round(n*dt, digits=2)) s\nЛевый конец: $(bc_left), Правый: $(bc_right)",
         label="Смещение струны",
         linewidth=2, color=:royalblue)
    
    # Добавляем линии для наглядности краевых условий
    if bc_left == :dirichlet
        plot!([0, 0], [-1.2, 1.2], linestyle=:dash, color=:red, label="Закреплённый конец (u=0)")
    else
        plot!([0, 0], [-1.2, 1.2], linestyle=:dash, color=:green, label="Свободный конец (uₓ=0)")
    end
    
    if bc_right == :dirichlet
        plot!([L, L], [-1.2, 1.2], linestyle=:dash, color=:red, label="")
    else
        plot!([L, L], [-1.2, 1.2], linestyle=:dash, color=:green, label="")
    end
end

# Сохраняем гифку
gif(anim, "string_reflection.gif", fps=30)
