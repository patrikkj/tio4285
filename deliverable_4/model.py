from collections import namedtuple
from itertools import product

import gurobipy as gp
import numpy as np
import pandas as pd
import xpress as xp

np.set_printoptions(edgeitems=30, linewidth=1000, precision=6, suppress=False)
np.set_printoptions(formatter={'float':lambda x: f"{x:.6f}"})
pd.set_option("precision", 6)


class EquilibriumModel:
    def __init__(self, params, flags=None):
        self.model = xp.problem()
        self.params = params
        self.flags = flags or {}
        self.vars = {}

        # Unpack parameters
        self.__dict__.update(params.__dict__)

        # Set parameter controlling 'Market power adjustment' 
        self.Y = 1 if self.flags.get("MARKET_TYPE") == "C" else 0

        # Inferred sets
        self.S = range(self.n_suppliers)
        self.N = range(self.n_nodes)
        self.SN = list(product(self.S, self.N))

    def add_variables(self):
        self.vars = {
            "Q_P": np.array([xp.var() for _ in self.S]),
            "Q_C": np.array([xp.var() for _ in self.SN]).reshape(self.n_suppliers, self.n_nodes)
        }
        self.__dict__.update(self.vars)
        self.model.addVariable(*self.vars.values())

    def set_objective(self):
        # Subexpressions
        self.Q_n = self.Q_C.sum(axis=0)                                 # Consumed quantity per node
        self.p_n = self.a - self.b * self.Q_n                           # Price per node
        self.f_n = self.c * self.Q_P + self.d * self.Q_P**2             # Production cost per supplier

        self.TC = xp.Sum(self.f_n + (self.c_f * self.Q_C).sum(axis=1))  # Total costs
        self.MPA = xp.Sum(0.5 * self.b * (self.Q_C**2).sum(axis=0))     # Market power adjustment
        self.CS = xp.Sum(0.5 * self.b * self.Q_n**2)                    # Consumer surplus
        self.REV = xp.Sum(self.p_n * self.Q_n)                          # Revenue

        # Objective function 
        obj = self.TC - self.CS - self.REV + self.Y * self.MPA
        self.model.setObjective(obj, sense=xp.minimize)
        
    def add_constraints(self):
        self.constraints = {
            # Transport capacity per arc
            "capacity_con": [self.Q_C[i,n] <= self.cap_f[i,n] for (i, n) in self.SN],
            
            # Supply must equal demand
            "supply_demand_con": [self.Q_P[i] == xp.Sum(self.Q_C[i,n] for n in self.N) for i in self.S]
        }
        self.__dict__.update(self.constraints)
        self.model.addConstraint(*self.constraints.values())

    def build_model(self):
        self.add_variables()
        self.set_objective()
        self.add_constraints()
        return self

    def solve(self):
        # Solve model in Gurobi
        self.model.write("./model", "lp")
        self.gurobi_model = gp.read("./model.lp")
        self.gurobi_model.setParam('OutputFlag', 0)
        self.gurobi_model.optimize()

        # Extract solution
        self.sol = self.get_solution()
        self.duals = self.get_duals()

        # Results
        if self.flags.get('PRINT_SOLUTION'):
            self.print_solution(self.sol)
        if self.flags.get('PRINT_VARIABLES'):
            self.print_variables(self.sol)

    def get_solution(self):
        """ Reads of the solution from the solved problem instance."""
        sizes = [v.size for v in self.vars.values()]
        shapes = [v.shape for v in self.vars.values()]
        flat_sols = [v.X for v in self.gurobi_model.getVars()]
        sols = np.split(flat_sols, np.array(sizes).cumsum()[:-1])
        sols = [sol.reshape(shape) for sol, shape in zip(sols, shapes)]
        dict_ = dict(zip(self.vars, sols))
        return namedtuple('Solution', dict_)(**dict_)

    def get_duals(self):
        """ Reads of the dual values from the solved problem instance."""
        sizes = [len(c) for c in self.constraints.values()]
        flat_duals = [c.Pi for c in self.gurobi_model.getConstrs()] 
        duals = np.split(flat_duals, np.array(sizes).cumsum()[:-1])
        dict_ = dict(zip(self.constraints, duals))
        return namedtuple('Duals', dict_)(**dict_)

    def print_variables(self, sol):
        for k, v in sol._asdict().items():
            print("\n")
            print(f"{'Solution for ' + k:^30}")
            print("="*30)
            print(v)

    def print_solution(self, sol):
        network_str = f"NETWORK_TYPE={self.flags.get('NETWORK_TYPE')}"
        market_str = f"MARKET_TYPE={self.flags.get('MARKET_TYPE')}"
        print(f"\n\n{'='*10} SOLUTION FOR [{network_str}, {market_str}] {'='*10}")
        print(f"\nOBJECTIVE: {self.gurobi_model.ObjVal}")
        
        # Subexpressions
        Q_n = sol.Q_C.sum(axis=0)                               # Consumed quantity per node
        p_n = self.a - self.b * Q_n                             # Price per node
        f_n = self.c * sol.Q_P + self.d * sol.Q_P**2            # Production cost per supplier

        TC = np.sum(f_n + (self.c_f * sol.Q_C).sum(axis=1))     # Total costs
        MPA = np.sum(0.5 * self.b * (sol.Q_C**2).sum(axis=0))   # Market power adjustment
        CS = np.sum(0.5 * self.b * Q_n**2)                      # Consumer surplus
        REV = np.sum(p_n * Q_n)                                 # Revenue

        print(f"TC:  {TC}")
        print(f"MPA: {MPA}")
        print(f"CS:  {CS}")
        print(f"REV: {REV}")

        # Answers to subtask (c)
        production = sol.Q_P
        consumption = sol.Q_C.sum(axis=0)
        price = self.a - self.b * consumption

        print(f"Production:  {production}")
        print(f"Consumption: {consumption}")
        print(f"Price:       {price}")
        print(f"\nTotal supplier profits (REV - TC): {REV - TC}")
        print(f"Total consumer surplus (CS):       {CS}")

        # Answers to subtask (e)
        indices = [(i+1, n+1) for i, n in self.SN]
        rows = [
            {
                "MR": self.a[n] - self.b[n] * consumption[n] - self.Y * self.b[n] * sol.Q_C[i, n],
                "MC": self.c[i] + 2 * self.d[i] * sol.Q_C[i,:].sum() + self.c_f[i,n],
                "Dual": self.duals.capacity_con[count]
            } for count, (i, n) in enumerate(self.SN)
        ]
        print("\n", pd.DataFrame(data=rows, index=indices), "\n", sep='')
