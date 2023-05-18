import glob
import os
import zipfile
from datetime import datetime
from pathlib import Path

start_date = datetime(2020, 1, 1).date()
end_date = datetime(2022, 12, 31).date()
dt = start_date
dest_path = Path("./Data/Raw/CAMS_NRT/unzipped")

if not dest_path.exists():
    dest_path.mkdir()

while dt < end_date:
    files = glob.glob(f"./Data/Raw/CAMS_NRT/cams_{dt}*")

    intermediate_path = Path.joinpath(dest_path, str(dt))
    for file in files:
        # file = files[0]
        file = Path(file)
        model_time = file.name.split("_")[2]
        step = file.name.split("_")[3].split(".")[0]
        with zipfile.ZipFile(file, "r") as zip_ref:
            zip_ref.extractall(intermediate_path)

        os.rename(
            glob.glob(f"{intermediate_path}/data.nc")[0],
            f"{intermediate_path}/{dt}_{step}_{model_time}.nc",
        )
