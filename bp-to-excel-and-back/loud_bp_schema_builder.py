import pickle as pickle
from dictionary_transformations import flatten, isDict, filterNestedDict

isList = lambda x : type(x) == list
isSet = lambda x : type(x) == set
isListOrSet = lambda x : isList(x) or isSet(x)
isListOfDicts = lambda xs : isList(xs) and len(xs) > 0 and isDict(xs[0])
typifyDict = lambda d : {k: set if type(v) == dict and len(v) > 0 else type(v) for k, v in d.items()} # mark empty dicts as sets
removeUidFromSchema = lambda d : {k: v for k, v in d.items() if k != ('uid',)}
      
def combineFlattenedDicts(d1, d2):
    commonKeys = d1.keys() & d2.keys()
    for k in commonKeys:
        if (isDict(d1[k]) and isListOrSet(d2[k])) or (isDict(d2[k]) and isListOrSet(d1[k])):
            raise Exception("One blueprint mapped a key to the type", d1[k], "while another mapped a key to the type", d2[k])
    return {**d1, **d2}

def buildSchema(bps):
    schema = {}
    for bp in bps:
        schema = combineFlattenedDicts(schema, typifyDict(flatten(bp)))
    # uids are not needed in the schemas, they are only used for row indices:
    return removeUidFromSchema(schema)

def main(file_prefix):
    unitBps = pickle.load(open(file_prefix+'_UNIT-BPS_BEFORE.pkl', 'rb'))
    weaponBps = pickle.load(open(file_prefix+'_WEAPON-BPS_BEFORE.pkl', 'rb'))
    # Remove 1:m relationships from units and weapons. Each 1:m rel would require a separate table
    # in a normalized database, so we omit these from the table schemas and only create sheets for
    # units + the 1:m relationships that we actually care about changing (i.e., weapons). If we
    # want to change any other 1:m relationships (e.g., sounds) then we will need to change the
    # codebase to explictly account for them.
    unitBps = [ filterNestedDict(lambda _, v : not isListOfDicts(v), bp) for bp in unitBps.values() ]
    weaponBps = [ filterNestedDict(lambda _, v : not isListOfDicts(v), w) for bp in weaponBps.values() for w in bp ]
    unitSchema = buildSchema(unitBps)
    weaponSchema = buildSchema(weaponBps)
    pickle.dump(unitSchema, open(file_prefix+'_UNIT-SCHEMA.pkl', 'wb+'))
    pickle.dump(weaponSchema, open(file_prefix+'_WEAPON-SCHEMA.pkl', 'wb+'))

if __name__ == "__main__":
    main('AEON-MOBILE')
