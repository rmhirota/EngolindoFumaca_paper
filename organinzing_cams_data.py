import glob
import os
import zipfile
from datetime import datetime
from pathlib import Path
import netCDF4
from dateutil.relativedelta import relativedelta

start_date = datetime(2020, 1, 1).date()
end_date = datetime(2022, 12, 31).date()
dt = start_date
dest_path = Path("./Data/Raw/CAMS_NRT/unzipped")

if not dest_path.exists():
    dest_path.mkdir()

while dt < end_date:
    files = glob.glob(f"./Data/Raw/CAMS_NRT/cams_{dt}*")

    for file in files:
        # file = files[0]
        file = Path(file)
        intermediate_path = Path.joinpath(dest_path, str(dt))
        model_time = file.name.split("_")[2]
        step = file.name.split("_")[3].split(".")[0]
        with zipfile.ZipFile(file, "r") as zip_ref:
            zip_ref.extractall(intermediate_path)

        os.rename(
            glob.glob(f"{intermediate_path}/data.nc")[0],
            f"{intermediate_path}/{dt}_{step}.nc",
        )


    dt += relativedelta(months=1)
    file_ls = glob.glob(f"{intermediate_path}/*.nc")
    nc = netCDF4.MFDataset(file_ls)

    nc_ = netCDF4.Dataset(f"{intermediate_path}/2022-12-01_6-9.nc")
    nc_.dimensions.get("time")
    nc_.variables['pm2p5'][:]
    time = nc_.variables['time']
    time[:]
    netCDF4.num2date(time[:], time.units)
    nc_.isopen()
    nc_.()
    nc2 = netCDF4.Dataset(f"{intermediate_path}/2022-12-01_0-3-6-9-12-15.nc")
    nc['time',::]

import xarray
xarray.open_mfdataset(file_ls)


    rootgrp = netCDF4.Dataset(f"{intermediate_path}/{dt}.nc", "w", format="NETCDF4")
    rootgrp.close()
nc_files = Path("./Data/Raw/CAMS_NRT/unzipped")

if not dest_path.exists():
    dest_path.mkdir()
