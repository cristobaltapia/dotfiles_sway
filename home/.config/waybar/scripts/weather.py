# Python program to find current
# weather details of any city
# using openweathermap api

# import required modules
import requests, json
from numpy import linspace, around

# Enter your API key here
api_key = "67e1af894e6079e8b5b79881505e2fb2"

# base_url variable to store url
base_url = "http://api.openweathermap.org/data/2.5/weather?"
# Give city name
city_id = "2825297"

# complete_url variable to store
# complete url address
complete_url = base_url + "appid=" + api_key + "&id=" + city_id

# get method of requests module
# return response object
response = requests.get(complete_url)

# json method of response object
# convert json format data into
# python format data
x = response.json()

percentages = around(linspace(0, 100, 9), 0)
codes = [
    "01d",
    "02d",
    "03d",
    "04d",
    "09d",
    "10d",
    "11d",
    "13d",
    "50d",
]

icon_codes = {c: p for c, p in zip(codes, percentages)}

# Now x contains list of nested dictionaries
# Check the value of "cod" key is equal to
# "404", means city is found otherwise,
# city is not found
if x["cod"] != "404":

    # store the value of "main"
    # key in variable y
    y = x["main"]

    # store the value corresponding
    # to the "temp" key of y
    current_temperature = y["temp"] - 273.15

    # store the value corresponding
    # to the "pressure" key of y
    current_pressure = y["pressure"]

    # store the value corresponding
    # to the "humidity" key of y
    current_humidiy = y["humidity"]

    # store the value of "weather"
    # key in variable z
    z = x["weather"]

    # Cluods in percentage
    current_clouds = x["clouds"]["all"]

    # store the value corresponding
    # to the "description" key at
    # the 0th index of z
    weather_description = z[0]
    code = weather_description["icon"]

    info = weather_description["description"]

    out = {
        "text": fr"Stuttgart {current_temperature:1.1f}°C",
        "tooltip": fr"Stuttgart {current_temperature:1.1f}°C, {info}",
        "percentage": icon_codes[code],
        "code": code,
    }
    print(json.dumps(out))

else:
    print(" City Not Found ")

