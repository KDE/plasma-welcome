#!/usr/bin/env python3
#
# SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
#
# SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
#

# Script to update the list of supporters in Supporters.qml using exported Donorbox data
# Removes anonymous supporters, performs de-duplication (on email) and sorts by date
# Usage: ./UpdateSupporters.py ~/Downloads/rawList.csv

import csv
from datetime import datetime
import os
import sys

def import_csv(input_file):
    columns = ["Name", "Donor Email", "Make Donation Anonymous", "Donated At"]
    data = []

    input_file = os.path.expanduser(input_file)

    with open(input_file, "r") as infile:
        reader = csv.DictReader(infile)

        for row in reader:
            donated_at = datetime.strptime(row["Donated At"], "%m/%d/%Y %H:%M:%S")
            row["Donated At"] = donated_at
            data.append({key: row[key] for key in columns})

    return data

def sort_date(data):
    return sorted(data, key=lambda x: x["Donated At"])

def remove_anon(data):
    out_data = []

    for row in data:
        for row in data:
            if row["Make Donation Anonymous"] == "no":
                out_data.append(row)

    return out_data

def dedup_email(data):
    unique_emails = set()
    out_data = []

    for row in data:
        email = row["Donor Email"]
        if email not in unique_emails:
            unique_emails.add(email)
            out_data.append(row)

    return out_data

def js_arr(data):
    return '["' + '", "'.join(row['Name'] for row in data) + '"]'

# Take input
if len(sys.argv) > 1:
    input_file = sys.argv[1]
else:
    input_file = input("Path of donators CSV: ")

# Process data
raw_data = import_csv(input_file)
donations = len(raw_data)

supporters_data = dedup_email(sort_date(raw_data))
supporters = len(supporters_data)

data = dedup_email(remove_anon(sort_date(raw_data)))
nonanon_supporters = len(data)

# Output stats
print("Donations:", donations)
print("Supporters:", supporters, "({0!s} non-anonymous, {1!s} anonymous)".format(nonanon_supporters, supporters - nonanon_supporters))

# Update Supporters.qml
with open("Supporters.qml", "r+") as file:
    lines = file.readlines()

    donators_line = "    readonly property var donators: "
    for i, line in enumerate(lines):
        if donators_line in line:
            lines[i] = donators_line + js_arr(data) + "\n"
            break

    file.seek(0)
    file.writelines(lines)
    file.truncate()
    file.close()

print("Updated Supporters.qml")
