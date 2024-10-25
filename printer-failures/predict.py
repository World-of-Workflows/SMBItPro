from datetime import timedelta

# Convert Installation_Date to datetime for calculations
printer_data['Installation_Date'] = pd.to_datetime(printer_data['Installation_Date'])

# Predict the failure date based on MTBF and installation date. 
# Assuming that 'MTBF' is given in hours, and the 'Frequency_of_Use' affects the rate of usage.
# We calculate the failure date by assuming that 1 unit of 'Frequency_of_Use' increases the usage rate proportionally.
printer_data['Predicted_Failure_Date'] = printer_data['Installation_Date'] + pd.to_timedelta(printer_data['MTBF'] / printer_data['Frequency_of_Use'], unit='h')

# Sort printers by predicted failure date to find the ones most likely to fail soon
top_10_printers = printer_data[['Printer_ID', 'Predicted_Failure_Date']].sort_values(by='Predicted_Failure_Date').head(10)

# Display the top 10 printers predicted to fail soon
import ace_tools as tools; tools.display_dataframe_to_user(name="Top 10 Printers Predicted to Fail Soon", dataframe=top_10_printers)
