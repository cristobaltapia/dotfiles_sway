#!/usr/bin/env python
"""
Script to obtain weather information from openweathermap [1] and feed
a custom block for waybar [2].

The information has to be provided in a configuration file ('weather.conf')
in the same forlder as the script. A sample of the configuration file looks like this:

    ```
    [DEFAULT]
    cityid=2825297
    apikey=67e1af894e6079e8b5b79881505e2fb2
    lang=de
    ```

The custom block in the waybar configuration should look like this, in order to use
the icons correctly:

    ```json
    "custom/weather": {
      "exec": "python ~/.config/waybar/scripts/weather.py",
      "return-type": "json",
      "interval": 1800,
      "format": " {}  {icon}",
      "tooltip": true,
      "format-icons": [
        "",
        "",
        " ",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
      ]
    },
    ```

The script is based on the script posted in[3]

[1] https://openweathermap.org/
[2] https://github.com/Alexays/Waybar
[3] https://www.geeksforgeeks.org/python-find-current-weather-of-any-city-using-openweathermap-api/

"""
import requests
import json
import datetime
import configparser
from numpy import linspace, around
import os

config = configparser.ConfigParser()
config.read(os.path.expandvars("${HOME}") + "/.config/waybar/scripts/weather.conf")

# Read config file information here
api_key = config["DEFAULT"]["apikey"]
city_id = config["DEFAULT"]["cityid"]
lang = config["DEFAULT"]["lang"]

# base_url variable to store url
base_url = "http://api.openweathermap.org/data/2.5/weather?"

# complete url address
complete_url = base_url + "appid=" + api_key + "&id=" + city_id + f"&lang={lang}"

# get method of requests module
# return response object
response = requests.get(complete_url)

# json method of response object
# convert json format data into
# python format data
x = response.json()

# Define 'percentages' for each weather code
percentages = around(linspace(0, 100, 19), 0)[:-1]

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
    "01n",
    "02n",
    "03n",
    "04n",
    "09n",
    "10n",
    "11n",
    "13n",
    "50n",
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

    # Get temperature in celsius
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

    # Get the weather description string
    weather_description = z[0]
    code = weather_description["icon"]

    # Get current time
    sunrise_int = x["sys"]["sunrise"]
    sunrise = datetime.datetime.fromtimestamp(sunrise_int)
    sr = "{h:02d}:{m:02d}".format(h=sunrise.hour, m=sunrise.minute)
    sunset_int = x["sys"]["sunset"]
    sunset = datetime.datetime.fromtimestamp(sunset_int)
    ss = "{h:02d}:{m:02d}".format(h=sunset.hour, m=sunset.minute)
    city = x["name"]

    info = weather_description["description"]

    # Day or night?
    if code[-1] == "d":
        daynight = "day"
    else:
        daynight = "night"

    out = {
        "text": fr"{current_temperature:1.1f}°C",
        "tooltip": (
            f"{city} • {current_temperature:1.1f}°C\n{info}"
            + f"\nSunrise: {sr}\nSunset: {ss}"
        ),
        "percentage": icon_codes[code],
        "code": code,
        "class": daynight,
    }

else:
    out = {
        "text": fr"Not found",
        "tooltip": fr"Stuttgart {current_temperature:1.1f}°C, {info}",
        "percentage": icon_codes["01d"],
        "code": code,
    }

print(json.dumps(out))
