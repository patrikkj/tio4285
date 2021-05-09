from dataclasses import dataclass

import numpy as np
import xpress as xp


@dataclass
class Params:
    n_suppliers: int    # Number of suppliers
    n_nodes: int        # Number of nodes
    a: np.ndarray       # Intercept of the inverse demand curve for node 'n'
    b: np.ndarray       # Slope of the inverse demand curve for node 'n'
    c: np.ndarray       # Constant cost term in production cost for supplier 'i'
    d: np.ndarray       # Increasing cost term in production cost for supplier 'i'
    cap_f: np.ndarray   # Transportation capacity from node 'n' to 'm'
    c_f: np.ndarray     # Unit transportation cost from node 'n' to 'm'

# Input data demand and supply
n_suppliers = 4
n_nodes = 4
a = np.array([100, 100, 100, 100])
b = np.array([0.5, 0.5, 0.5, 0.5])
c = np.array([10, 10, 10, 10])
d = np.array([1, 1, 1, 1])

# Network - Variant A
params_a = Params(
    n_suppliers=n_suppliers,
    n_nodes=n_nodes,
    a=a, b=b, c=c, d=d,
    cap_f=np.array([
        [1e9, 10, 10, 10],
        [0, 1e9, 10, 10],
        [0, 0, 1e9, 10],
        [0, 0, 0, 1e9],
    ]),
    c_f=np.array([
        [0, 2, 2, 2],
        [0, 0, 2, 2],
        [0, 0, 0, 2],
        [0, 0, 0, 0]
    ])
)

# Network - Variant B
params_b = Params(
    n_suppliers=n_suppliers,
    n_nodes=n_nodes,
    a=a, b=b, c=c, d=d,
    cap_f=np.array([
        [1e9, 5, 6, 6],
        [6, 1e9, 6, 6],
        [6, 6, 1e9, 6],
        [6, 6, 6, 1e9],
    ]),
    c_f=np.array([
        [0, 5, 5, 5],
        [5, 0, 5, 5],
        [5, 5, 0, 5],
        [5, 5, 5, 0]
    ])
)
