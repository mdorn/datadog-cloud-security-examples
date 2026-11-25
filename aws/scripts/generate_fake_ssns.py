#!/usr/bin/env python3
"""Generate SYNTHETIC customer records with SSN-formatted numbers for the SDS demo.

Numbers follow the valid SSN shape (area not 000/666/9xx, group not 00, serial not 0000)
so Datadog's US SSN library rule matches them. They are random, tied to invented names,
and must never be replaced with real data.

Usage: python3 scripts/generate_fake_ssns.py > data/customer_records.txt
"""
import random

SEED = 20261124
ROWS = 25

FIRST = ["Avery", "Jordan", "Casey", "Riley", "Morgan", "Quinn", "Rowan", "Skyler",
         "Harper", "Emerson", "Finley", "Reese", "Sawyer", "Parker", "Dakota"]
LAST = ["Testwell", "Samplesby", "Mockford", "Fakeley", "Dummond", "Placeman",
        "Examplar", "Synthers", "Notreal", "Labworth"]
CITIES = ["Springfield, IL", "Fairview, TX", "Riverton, WY", "Franklin, TN", "Greenville, SC"]

# Well-known "advertising" SSNs that scanners often ignore.
SKIP = {"078-05-1120", "219-09-9999", "123-45-6789"}


def fake_ssn(rng):
    while True:
        area = rng.randint(1, 899)
        if area == 666:
            continue
        ssn = "%03d-%02d-%04d" % (area, rng.randint(1, 99), rng.randint(1, 9999))
        if ssn not in SKIP:
            return ssn


def main():
    rng = random.Random(SEED)
    print("Example Retail Co. customer export (SYNTHETIC TEST DATA, NOT REAL PEOPLE)")
    print("Generated for the Datadog attack path lab. Do not use outside the sandbox.")
    print()
    print("customer_id | full_name | date_of_birth | social_security_number | city")
    for i in range(1, ROWS + 1):
        name = "%s %s" % (rng.choice(FIRST), rng.choice(LAST))
        dob = "%04d-%02d-%02d" % (rng.randint(1950, 2000), rng.randint(1, 12), rng.randint(1, 28))
        print("CUST-%05d | %s | %s | SSN: %s | %s" % (1000 + i, name, dob, fake_ssn(rng), rng.choice(CITIES)))


if __name__ == "__main__":
    main()
