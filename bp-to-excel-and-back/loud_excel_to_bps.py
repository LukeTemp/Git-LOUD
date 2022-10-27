import xlrd
import pandas as pd
from slpp import slpp as lua
import numpy as np
import pickle as pickle
import copy
from dictionary_transformations import nest, filterDict

def parseDictsFromRows(dataframe,numOfRows,schema):
    rawRows = [list(dataframe.iloc[i]) for i in range(numOfRows)]
    return [{k : v for k, v in zip([('uid',)] + list(schema.keys()), r)} for r in rawRows]

# A string representation of None is used since pandas converts the None type to nan when exporting to excel documents.
def parseNoneInDict(d):
    return {k : None if v == '<<<NONE>>>' else v for k, v in d.items()}

def cleanDict(d):
    return parseNoneInDict( filterDict(lambda k, v : k != ('uid',) and v != '-',d) )

def main(file_prefix):
    unitSchema = pickle.load(open(file_prefix+'_UNIT-SCHEMA.pkl', 'rb'))
    weaponSchema = pickle.load(open(file_prefix+'_WEAPON-SCHEMA.pkl', 'rb'))
    unitBps = pickle.load(open(file_prefix+'_UNIT-BPS_BEFORE.pkl', 'rb'))
    weaponBps = pickle.load(open(file_prefix+'_WEAPON-BPS_BEFORE.pkl', 'rb'))

    units = pd.read_excel( file_prefix+"_DATA.xlsx"
                         , 'Unit'
                         , skiprows=max(map(len,unitSchema.keys()))+1 )
    weapons = pd.read_excel( file_prefix+"_DATA.xlsx"
                           , 'Weapon'
                           , skiprows=max(map(len,weaponSchema.keys()))+1 )

    unitRowDicts = parseDictsFromRows(units,len(unitBps),unitSchema)
    weaponRowDicts = parseDictsFromRows(weapons,len([w for ws in weaponBps.values() for w in ws]),weaponSchema)

    unitBpsAfter = { d[('uid',)] : cleanDict(d) for d in unitRowDicts }
    weaponBpsAfter = { uid : [ cleanDict(d) for d in weaponRowDicts if d[('uid',)] == uid] for uid in weaponBps.keys() }

    pickle.dump({uid : nest(bp) for uid, bp in unitBpsAfter.items()}, open(file_prefix+'_UNIT-BPS_AFTER.pkl', 'wb+'))
    pickle.dump({uid : list(map(nest,bps)) for uid, bps in weaponBpsAfter.items()}, open(file_prefix+'_WEAPON-BPS_AFTER.pkl', 'wb+'))
    
if __name__ == "__main__":
    main('AEON-MOBILE')
