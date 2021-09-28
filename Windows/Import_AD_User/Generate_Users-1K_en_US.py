#!/usr/local/bin/python3
# -*- coding: utf-8 -*-

import faker
import pprint
import random

tableau=[]
from faker import Faker
fake = Faker('en_US')

for i in range(10000):
    age=random.randint(18,99)
    tableau.append((i,fake.first_name(),fake.last_name()))

pprint.pprint(tableau)

with open("users.csv", "w") as file:
    for element in tableau:
        file.write(f"{str(element[0])};{str(element[1])};{str(element[2])}\n")
