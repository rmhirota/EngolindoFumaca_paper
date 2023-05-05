import cdsapi
from datetime import date, timedelta
import time as t
import calendar
from dateutil.relativedelta import relativedelta
from pathlib import Path
import logging

server = cdsapi.Client()
PATH = Path('./Data/Raw/CAMS_NRT/')
PARAMS = {
    "type": "forecast",
    "format": "netcdf_zip",
    "variable": "particulate_matter_2.5um",
    "date": f"2023-05-01/2023-05-02",
    "time": [
        "00:00",
        "12:00",
    ],
    "area": [6.1599998802974305, -73.99, -18.04, -43.3899994411983982],
    "leadtime_hour": [
        "0",
        "12",
        "6",
    ],
}

START_DATE = date(2021, 1, 1)
END_DATE = date(2022, 12, 31)

times = ["00:00", "12:00"]
dt = START_DATE
dt_end = dt.replace(day=calendar.monthrange(dt.year, dt.month)[1])

if not PATH.exists():
    PATH.mkdir()

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
        file_name = Path(
            f"{PATH}/cams_{params['date'].replace('/', '-')}_{params['time']}_{'-'.join(list(map(str, params['leadtime_hour'])))}.netcdf_zip"
        )
        if file_name.exists():
            logging.warning(f"File {file_name} already exists. Skipping it.")
        else:
            logging.warning(f'Retriving {time} for {params["date"]}')
            server.retrieve(
                "cams-global-atmospheric-composition-forecasts",
                params,
                file_name,
            )
            t.sleep(10)
            logging.warning(f'Done {time} for {params["date"]}')
    logging.warning(f"Done {dt}")
    dt += relativedelta(months=1)
