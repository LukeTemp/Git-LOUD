from pathlib import Path
from slpp import slpp as lua
import os
import pickle as pickle

def isDict(x):
    return type(x) == dict

def filterDict(f,d):
    return {k : v for k, v in d.items() if f(k,v)}

def filterNestedDict(f,d):
    return {k : filterNestedDict(f,v) if isDict(v) else v for k, v in d.items() if isDict(v) or f(k,v)}

def flatten(d,keyList=[]):
    """Flattens a nested dictionary using depth first traversal"""
    entries = {}
    for k,v in d.items():
        newKeyList = keyList + [k]
        if isDict(v):
            subDict = flatten(v,newKeyList)
            if len(subDict) == 0:
                entries[tuple(newKeyList)] = v
            else:
                entries = {**entries, **subDict}
        else:
            entries[tuple(newKeyList)] = v
    return entries

def nest(d):
    """Nests a flattened dictionary"""

    def getValForOuterKey(outerKey):
        dictForOuterKey = {}
        for k, v in d.items():
            if k[0] == outerKey:
                if len(k) == 1:
                    return v
                dictForOuterKey[k[1:]] = v
        return nest(dictForOuterKey)
                
    nestedDict = {}
    allOuterKeys = set([k[0] for k in d.keys()])
    for outerKey in allOuterKeys:
        nestedDict[outerKey] = getValForOuterKey(outerKey)
    return nestedDict

def testIdentity(nestedDict, flattenedDict):
    return nestedDict == nest(flatten(nestedDict)) and flattenedDict == flatten(nest(flattenedDict))

if __name__ == "__main__":
    unitBps = pickle.load(open('AEON-MOBILE_UNIT-BPS_BEFORE.pkl', 'rb'))
    allBpsPassIdentityTest = all([testIdentity(unitBps[0], flatten(unitBps[0])) for bp in unitBps])
    print(len(unitBps), "unit bps can be converted to/from flattened dictionaries while satisfying identity properties:", allBpsPassIdentityTest)
