# GroundwaterDataSort
This code sorts groundwater data acquired from Iran's authorities (Water regional companies) based on station names while trying to improve its shortcomings.
1- Finds unique values of ground water stations and crop them.
2- Counts each station data and removes any station that has less than 10 years of data.
3- Counts the NaN values and enforces a 30% threshold.
4- For stations that remain after this screening process, NaN values are replaced by extrapolation of adjacent values.
