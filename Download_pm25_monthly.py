import cdsapi
from datetime import date, timedelta
import time as t
import calendar
from dateutil.relativedelta import relativedelta

server = cdsapi.Client()

PARAMS = {
    "class": "mc",
    "dataset": "cams_nrealtime",
    "date": "2020-08-01",
    "expver": "0001",
    "levtype": "sfc",
    "param": "73.210",
    "step": "6/9",
    "stream": "oper",
    "time": "00:00:00",
    "type": "fc",
    "target": "./Data/Raw/CAMS/NRT/LIXO.nc",
    "area": "5.27/-73.99/-18.04/-44",
    "grid": "0.4/0.4",
    "format": "netcdf"
}

START_DATE = date(2020, 2, 1)
END_DATE = date(2020, 3, 1)

times = ['00:00:00', '12:00:00']
dt = START_DATE
dt_end = dt.replace(day = calendar.monthrange(dt.year, dt.month)[1])
while dt < END_DATE:
    params = PARAMS.copy()
    dt_end = dt.replace(day=calendar.monthrange(dt.year, dt.month)[1])
    params["date"] = f'{dt.strftime("%Y-%m-%d")}/to/{dt_end.strftime("%Y-%m-%d")}'
    for time in times:
        # time = times[0]
        params["time"] = time
        if time == "00:00:00": # se time 00:00:00 baixar steps 6/9
            params["step"] = "6/9"
        else: #se não, sera 12:00:00, entao baixar step "0/3/6/9/12/15"
            params["step"] = "0/3/6/9/12/15"

        params["target"] = f"./Data/Raw/CAMS/NRT/cams_{params['date'].replace('/', '-')}_{params['grid'].replace('/', '-')}_{params['time'].replace(':', '-')}_{params['step'].replace('/', '-')}_.nc"
        print(f'Retriving {time} for {params["date"]}')
        server.retrieve(params)
        t.sleep(10)
        print(f'Done {time} for {params["date"]}')
    print(f'Done {dt}')
    dt += relativedelta(months=1)
