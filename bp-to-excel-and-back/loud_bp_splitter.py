from pathlib import Path
import os
import pickle as pickle
from dictionary_transformations import filterDict
from mySlpp.slpp import slpp as lua

def readBlueprints(dirs, categories, logging):
    #Use categories to filter which blueprints are collected:
    blueprints, flaggedUids = {}, []
    for d in dirs:
        files = Path(d).rglob('*_unit.bp') #Path(d).rglob('*U*_*.bp')
        for f in files:
            filedata = open(f, 'r').read()
            if filedata.strip().startswith("UnitBlueprint {"):
                filedata = filedata.replace("UnitBlueprint {", "{") \
                                   .replace(" = Sound {", "_SOUND = {") # drop UnitBlueprint constructor and Sound constructor, leaving raw table
                unitBlueprint = lua.decode(filedata,logging)
                uid = os.path.basename(f).split('_')[0]
                if 'Categories' not in unitBlueprint:
                    if logging:
                        print('No categories found in:', f)
                elif 'COMMAND' in unitBlueprint['Categories']: # exclude commanders
                    if logging:
                        print('Command unit found at:', f, '; skipping this unit.')
                elif uid in blueprints.keys():
                    if logging:
                        print("The uid", uid, "was found in more than 1 .bp file:", blueprints[uid]['path'], "and", f, ". This unit will be skipped.")
                    flaggedUids = flaggedUids + [uid]
                elif categories.issubset(unitBlueprint['Categories']):
                    blueprints = {**blueprints, **{uid : {"blueprint" : unitBlueprint, "path" : f}}}
    return filterDict(lambda k, _ : k not in flaggedUids, blueprints)

def main(dirs, categories, file_prefix, logging=True):
    bps = { k : bp['blueprint'] for k, bp in readBlueprints(dirs, categories, logging).items() }
    # Separate the unit blueprints:
    unitBps = { uid : filterDict(lambda k, _ : k != 'Weapon', bp) for uid, bp in bps.items() }
    # Separate the weapon blueprints:
    weaponBps = { uid : bp['Weapon'] for uid, bp in bps.items() if 'Weapon' in bp.keys() }
    # Save files:
    pickle.dump(unitBps, open(file_prefix+'_UNIT-BPS_BEFORE.pkl', 'wb+'))
    pickle.dump(weaponBps, open(file_prefix+'_WEAPON-BPS_BEFORE.pkl', 'wb+'))
    # 1:m relationships are not filtered out at this point, otherwise they would be removed from every unit bp after saving changes.

if __name__ == "__main__":
    dirs = ['C:/Program Files (x86)/Steam/steamapps/common/Supreme Commander Forged Alliance/Git-LOUD/gamedata/']
    main(dirs, {'AEON', 'MOBILE'}, 'AEON-MOBILE')
