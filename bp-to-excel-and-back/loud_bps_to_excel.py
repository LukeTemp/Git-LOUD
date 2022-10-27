import xlrd
import pandas as pd
from slpp import slpp as lua
import numpy as np
import pickle as pickle
import copy
from dictionary_transformations import flatten

def normalizeKeys(d): # this function slows down the script quite a bit?

    def normalize(k,n):
        kList = list(k)
        for i in range(len(kList),n):
            kList = kList + ['-']
        return tuple(kList)
    
    n = max(map(len,d.keys()))
    return {normalize(k,n) : v for k, v in d.items()}

# A string representation of None is used since pandas converts the None type to nan when exporting to excel documents.
def convertNone(v):
    if v == None:
        return '<<<NONE>>>'
    else:
        return v

def mkColumns(schema,blueprints):
    columns = {}
    for k, v in schema.items():
        newKey = tuple(list(k)+[v])
        columns[newKey] = [] # append type onto key
        for bp in map(flatten,blueprints):
            columns[newKey] = columns[newKey] + [ convertNone(bp[k]) if k in bp.keys() else '-' ]
    return columns

def mkDataFrame(columns,indices):
    return pd.DataFrame(data=normalizeKeys(columns), index=indices)

def main(file_prefix):
    unitSchema = pickle.load(open(file_prefix+'_UNIT-SCHEMA.pkl', 'rb'))
    weaponSchema = pickle.load(open(file_prefix+'_WEAPON-SCHEMA.pkl', 'rb'))
    unitBps = pickle.load(open(file_prefix+'_UNIT-BPS_BEFORE.pkl', 'rb'))
    weaponBps = pickle.load(open(file_prefix+'_WEAPON-BPS_BEFORE.pkl', 'rb'))
    unitDF = mkDataFrame(mkColumns(unitSchema,unitBps.values()), unitBps.keys())
    flatWeaponBps = [w for ws in weaponBps.values() for w in ws]
    flatWeaponUids = [k for k, ws in weaponBps.items() for w in ws]
    weaponDF = mkDataFrame(mkColumns(weaponSchema,flatWeaponBps), flatWeaponUids)
    with pd.ExcelWriter(file_prefix+"_DATA.xlsx") as writer:
        unitDF.to_excel(writer,sheet_name='Unit')
        weaponDF.to_excel(writer,sheet_name='Weapon')

if __name__ == "__main__":
    main('AEON-MOBILE')
