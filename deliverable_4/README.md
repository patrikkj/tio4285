# Market equilibrium model
Implementation of the mathematical model using the [FICO Xpress Optimizer Python interface](https://www.msi-jp.com/xpress/manual/pdf/12-python-interface.pdf) and [Gurobi Solver Python interface](https://www.gurobi.com/documentation/9.1/quickstart_mac/cs_grbpy_the_gurobi_python.html).


---
### Setup
The model implementation requires Python 3.8 or above which can be downloaded from [this link](https://www.python.org/downloads/).

1. Navigate to the project root directory and install required dependencies by running
```sh
# Windows
pip install -r requirements.txt

# MacOS / Linux
pip3 install -r requirements.txt
```

2. Make sure that your FICO Xpress installation contains a valid license. To use an alternative license file, set the `XPAUTH_PATH` environment variable to the full path to your license file, `xpauth.xpr`. Students can apply for an academic license for free [here](https://www.fico.com/en/xpress-academic-license).

3. Make sure that your Gurobi installation contains a valid license. Students can apply for an academic license for free [here](https://www.gurobi.com/academia/academic-program-and-licenses/).

---
### Run
In order to run the model, simply execute the python script by running

```sh
# Windows
python main.py

# MacOS / Linux
python3 main.py
```
depending on your operating system. 

---
### Input parameters and flags

##### Flags and controls
A series of flags are defined which can be set to alter the flow of the program. These are defined in `main.py` as follows:
```python
flags = {
    'PRINT_VARIABLES': True,    # Whether to print values of decision variables
    'PRINT_SOLUTION': True,     # Whether to print solution details
    'NETWORK_TYPE': "A",        # One of: {"A", "B"}
    'MARKET_TYPE': "C"          # One of: {"C" = Cournot, "P" = Perfect competition}
}
```


##### Input parameters
Problem-specific parameters are defined in `data.py` in the following format:

```python
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
```