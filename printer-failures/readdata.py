import pandas as pd

# Load the dataset to inspect the data
file_path = '/mnt/data/Printer_Failure_Prediction_Data.csv'
printer_data = pd.read_csv(file_path)

# Display the first few rows of the data to understand its structure
printer_data.head()
