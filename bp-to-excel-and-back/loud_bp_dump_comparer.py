import pickle as pickle
import ast
from dictionary_transformations import isDict

def aggregate(new, old):
    """ always assigns new values over old values """
    if isDict(new) and isDict(old):
        return combineDicts(new,old)
    else:
        if type(new) == str and type(old) != str:
            return ast.literal_eval(new)
        else:
            return new

def combineDicts(new, old): # move this into dictionary transformations? Along with aggregate.
    combined = new.copy()
    for k, v in old.items():
        if k in combined:
            combined[k] = aggregate(combined[k],v)
        else:
            combined[k] = v
    return combined

def compareDicts(before,combined): # TO DO: Coerce types in bp after to match the types in bp before, if they are different.
    if before.keys() != combined.keys():
        print("FAIL: the UIDs between before and after do not match")
        return
    for uid in before.keys():
        # if corresponding keys don't map to equivalent values
        # because those values have different types, coerce
        # the types and then try. If still unequal then fail.
        if before[uid].keys() != combined[uid].keys():
            print("FAIL: the keys between before and after for unit", uid, "do not match")
            print(before[uid].keys())
            print(combined[uid].keys())
            return
        for k in before[uid].keys():
            if before[uid][k] != combined[uid][k]:
                print("FAIL: the value for key", k, "in before and after do not match for unit", uid)
                print(before[uid][k])
                print(combined[uid][k])

def main(file_prefix):
    unitBpsBefore = pickle.load(open(file_prefix+'_UNIT-BPS_BEFORE.pkl', 'rb'))
    unitBpsAfter = pickle.load(open(file_prefix+'_UNIT-BPS_AFTER.pkl', 'rb'))
    unitBpsCombined = { uid : combineDicts(unitBpsAfter[uid], bpBefore) for uid, bpBefore in unitBpsBefore.items() }
    compareDicts(unitBpsBefore, unitBpsCombined)
    
    weaponBpsAfter = pickle.load(open(file_prefix+'_WEAPON-BPS_AFTER.pkl', 'rb'))
    weaponBpsBefore = pickle.load(open(file_prefix+'_WEAPON-BPS_BEFORE.pkl', 'rb'))
    weaponBpsCombined = { uid : [combineDicts(wAfter, wBefore) for wAfter, wBefore in zip(weaponBpsAfter[uid], ws)] for uid, ws in weaponBpsBefore.items() }
    
    bpsBefore   = { uid : {**{'Weapon' : weaponBpsBefore[uid]}  , **bp} if uid in weaponBpsBefore.keys()   else bp for uid, bp in unitBpsBefore.items()   }
    bpsCombined = { uid : {**{'Weapon' : weaponBpsCombined[uid]}, **bp} if uid in weaponBpsCombined.keys() else bp for uid, bp in unitBpsCombined.items() }
    compareDicts(bpsBefore, bpsCombined)

    print(unitBpsBefore == unitBpsCombined)
    print(weaponBpsBefore == weaponBpsCombined)
    print(bpsBefore == bpsCombined)
    
if __name__ == "__main__":
    main('AEON-MOBILE')

