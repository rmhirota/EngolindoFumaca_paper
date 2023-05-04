import cdsapi
from datetime import date, timedelta
import time as t
import calendar
from dateutil.relativedelta import relativedelta

server = cdsapi.Client()

PARAMS = {
    "type": "forecast",
    "format": "netcdf_zip",
    "variable": "particulate_matter_2.5um",
    "date": f"2023-05-01/2023-05-02",
    "time": [
        "00:00",
        "12:00",
    ],
    "area": [5.27, -73.99, -18.04, -44],
    "leadtime_hour": [
        "0",
        "12",
        "6",
    ],
}

START_DATE = date(2020, 2, 1)
END_DATE = date(2020, 3, 1)

times = ["00:00", "12:00"]
dt = START_DATE
dt_end = dt.replace(day=calendar.monthrange(dt.year, dt.month)[1])
while dt < END_DATE:
    params = PARAMS.copy()
    dt_end = dt.replace(day=calendar.monthrange(dt.year, dt.month)[1])
    params["date"] = f'{dt.strftime("%Y-%m-%d")}/{dt_end.strftime("%Y-%m-%d")}'
    for time in times:
        # time = times[0]
        params["time"] = time
        if time == "00:00":  # se time 00:00 baixar steps 6/9
            params["leadtime_hour"] = [6, 9]
        else:  # se não, sera 12:00, entao baixar step "0/3/6/9/12/15"
            params["leadtime_hour"] = [0, 3, 6, 9, 12, 15]

        print(f'Retriving {time} for {params["date"]}')
        server.retrieve(
            "cams-global-atmospheric-composition-forecasts",
            params,
            f"./Data/Raw/CAMS_NRT/cams_{params['date'].replace('/', '-')}_{params['time']}_{'-'.join(list(map(str, params['leadtime_hour'])))}_.netcdf_zip",
        )
        t.sleep(10)
        print(f'Done {time} for {params["date"]}')
    print(f"Done {dt}")
    dt += relativedelta(months=1)
