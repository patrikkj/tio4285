# SARIMA example
import statsmodels.api as sm
from statsmodels.tsa.api import ExponentialSmoothing, SimpleExpSmoothing, Holt
from statsmodels.tsa.statespace.sarimax import SARIMAX
from random import random
import pandas as pd 
import matplotlib.pyplot as plt 
import numpy as np

df = pd.read_excel(f'/Users/Adrian/8. Semester/TIØ4285 Produksjons- og nettverksøkonomi/exercise01(1).xlsx',engine='openpyxl')
data = df.Deviation.values

# fit model
model = SARIMAX(data, order=(10, 3, 1), seasonal_order=(0, 0, 0, 0))
model_fit = model.fit(disp=False)
# make prediction
yhat = model_fit.predict(150,160)
print(yhat)
print(data)

res = np.hstack([ data, yhat])
plt.plot(range(161), res)
plt.show()


# Augmented Dicky-fuller test 

from statsmodels.tsa.stattools import adfuller

X = data

result = adfuller(X)
print('ADF Statistic: %f' % result[0])
print('p-value: %f' % result[1])
print('Critical Values:')
for key, value in result[4].items():
    print('\t%s: %.3f' % (key, value))


# Holts linear method 
fit_holt = Holt(np.asarray(data)).fit(smoothing_level = 0.5,smoothing_slope = 0.1)

test['Holt_linear_model'] = fit_holt.forecast(len(test))

mean_absolute_percentage_error(test.sales, test.Holt_linear_model)