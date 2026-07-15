from pathlib import Path
import pandas as pd
import re

source_folder = Path(r"GitHub/TilburgMultiscaleSummerschool2026/Datasets/BalanceCorpus/OpenFace/OF_output")
destination_folder = Path(r"GitHub/new_data")
destination_folder.mkdir(parents=True, exist_ok=True)

# Keeping certain columns, like the x(17-26) and y(17-26) coordinates, which are for the eyebrows in Open Face, and x33 and y33, which is for the tip of the nose
columns_to_keep = ['frame', 'face_id', 'timestamp', 'confidence', 'success', 
                   'x_17', 'x_18', 'x_19', 'x_20', 'x_21', 'x_22', 'x_23', 
                   'x_24', 'x_25', 'x_26', 'y_17', 'y_18', 'y_19', 'y_20', 
                   'y_21', 'y_22', 'y_23', 'y_24', 'y_25', 'y_26', 'x_33', 
                   'y_33']

pattern = re.compile(r"^(\d+_\d+)_\d+_\d+_\d{8}_\d{6}_(.+_cam01)\.csv$")

for csv_file in source_folder.rglob("*.csv"):

    # Only keeping the camera 1 files, so ignoring camera 2
    if "cam01" not in csv_file.name:
        print(f"Skipping: {csv_file.name}") # Sanity check
        continue

    match = pattern.match(csv_file.name)
    # To ignore the files that are also in the source folder that are not relevant, even if they have 'cam01' in the file name 
    if not match:
        print(f"Skipping: {csv_file.name}") # Another sanity check
        continue

    new_name = f"{match.group(1)}_{match.group(2)}.csv"

    df = pd.read_csv(csv_file, sep=',', skipinitialspace=True) # The original csv files contain a lot of whitespace

    # Only keeping the above pre-selected columns, so ignoring the other face points such as eye coordinates
    existing_columns = [c for c in columns_to_keep if c in df.columns]
    df = df[existing_columns]

    output_path = destination_folder / new_name
    df.to_csv(output_path, index=False)

    print(f"Saved: {new_name}")