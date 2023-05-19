from csv import DictReader
from pathlib import Path


def load_element_codes():
    codes = dict()
    with open(Path(__file__).with_name("element_codes.csv"), newline='') as codes_csv:
        for row in DictReader(codes_csv):
            time_period = row["time_period"]
            if time_period in codes:
                codes[time_period].add(row["abbreviation"])
            else:
                codes[time_period] = set()
    return codes


def get_element_abbreviation_by_time_period(time_period: str):
    return list(ABREVIATIONS.get(time_period, set()))


ABREVIATIONS = load_element_codes()
