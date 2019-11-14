using JuMP, Clp, Printf

d = [40 60 75 25]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40)       # boats produced with regular labor
@variable(m, y[1:4] >= 0)             # boats produced with overtime labor
@variable(m, inc[1:4] >= 0)
@variable(m, dec[1:4] >= 0)  
@variable(m, hinc[1:4] >= 0)
@variable(m, hdec[1:4] >= 0)  

@constraint(m, hinc[4] >= 10)
@constraint(m, hdec[4] <= 0) 
@constraint(m, x[1]+y[1]-50 == inc[1] + dec[1])
@constraint(m, flow1[i in 2:4], x[i] + y[i] -(x[i-1] + y[i-1]) == inc[i] + dec[i])     # conservation of boats
@constraint(m, 10+x[1]+y[1]-40 == hinc[1]-hdec[1])
@constraint(m, flow2[i in 2:4], hinc[i-1] - hdec[i-1] + x[i] + y[i] - d[i] == hinc[i] + hdec[i])     # conservation of boats

@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(hinc) + 400*sum(inc) + 500*sum(dec) + 100*sum(hdec))         # minimize costs

optimize!(m)

@printf("Boats to build regular labor: %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories: %d %d %d %d %d\n ", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))

@printf("Objective cost: %f\n", objective_value(m))