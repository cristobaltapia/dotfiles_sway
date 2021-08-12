#!/usr/bin/env python
from datetime import date
from textwrap import fill, wrap, shorten
import numpy as np

import pandas as pd


def main():
    # Read plan
    plan = pd.read_excel("~/Nextcloud/five_year_plan.xlsx", index_col=0)

    out = format_output(plan)
    print(out)


def format_output(data):
    """Format to correct pango markup.

    Parameters
    ----------
    data : TODO

    Returns
    -------
    TODO

    """
    width = 35
    year = date.today().year
    next_year = year + 1
    list_plan = "".ljust(12) + f"{year}".ljust(width) + f"{next_year}".ljust(width) + "\n"
    for k in data.index:
        elements_1 = str(data.loc[k, year]).split("/")
        elements_2 = str(data.loc[k, next_year]).split("/")

        elements_month = max(len(elements_1), len(elements_2))

        month = shorten(f"{k}", 3, placeholder="") + "  "

        list_1 = []
        list_2 = []

        for j in range(elements_month):
            m1 = elements_1[j] if j < len(elements_1) else ""
            m2 = elements_2[j] if j < len(elements_2) else ""

            if m1 == "nan":
                m1 = "".ljust(width)
            else:
                m1 = shorten(str(m1), width).ljust(width)

            list_1.append(m1)

            if m2 == "nan":
                m2 = "".ljust(width)
            else:
                m2 = shorten(str(m2), width).ljust(width)

            list_2.append(m2)

        start = "".ljust(5)
        for k in range(len(list_1)):
            month1 = f'<span foreground="#81a1c1">{list_1[k]}</span>'
            month2 = f'<span foreground="#ebcb8b">{list_2[k]}</span>'
            if k > 0:
                list_plan += f"{start}{month1} {start}{month2}\n"
            else:
                list_plan += f"{month}{month1} {month}{month2}\n"

    base = f"""<span face="monospace">
<span foreground="#eeeeee">
{list_plan}
</span>
</span>"""

    return base

if __name__ == "__main__":
    main()
