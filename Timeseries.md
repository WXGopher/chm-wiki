Time series data are input in a tab delimitated format. The only required column name is ```datetime```. Datetime format is ISO standard as [year][month][day]T[hour][minute][second]. Column order does not matter. The model may start at any time, however there is an assumption of constant time stepping. The difference in time_0 and time_1 is used to determine the internal model timesteps. The variable names in the columns must be the same names as what the interpolation modules expect. Missing values are permitted and should be set to -9999.

```
datetime	qsi	g	t	rh	u	vw_dir	p
20001001T000000	-0.237	-2.436	-10.98	95.7	2.599	308.2	0.0
20001001T003000	-0.233	-2.42	-11.19	95.7	3.133	307.1	0.0
```

This format is easily parseable with Pandas in Python
```python
obs = pd.read_csv("uc_2005_2014.txt",sep="\t",parse_dates=[0])
obs.set_index('datetime',inplace=True)
```

Various conversion scripts for other models' input/output are located in ```tools```