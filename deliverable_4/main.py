from data import params_a, params_b
from model import EquilibriumModel

flags = {
    'PRINT_VARIABLES': True,    # Whether to print values of decision variables
    'PRINT_SOLUTION': True,     # Whether to print solution details
    'NETWORK_TYPE': "A",        # One of: {"A", "B"}
    'MARKET_TYPE': "C"          # One of: {"C" = Cournot, "P" = Perfect competition}
}

# Run one instance
# params = params_a if flags.get('NETWORK_TYPE') == "A" else params_b
# EquilibriumModel(params=params, flags=flags).build_model().solve()

# Run all four configurations
EquilibriumModel(params=params_a, flags={**flags, 'MARKET_TYPE': "P", 'NETWORK_TYPE': "A"}).build_model().solve()
EquilibriumModel(params=params_b, flags={**flags, 'MARKET_TYPE': "P", 'NETWORK_TYPE': "B"}).build_model().solve()
EquilibriumModel(params=params_a, flags={**flags, 'MARKET_TYPE': "C", 'NETWORK_TYPE': "A"}).build_model().solve()
EquilibriumModel(params=params_b, flags={**flags, 'MARKET_TYPE': "C", 'NETWORK_TYPE': "B"}).build_model().solve()
