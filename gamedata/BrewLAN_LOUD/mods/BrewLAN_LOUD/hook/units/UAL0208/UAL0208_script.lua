local ConstructionUnit = UAL0208
local RegularAIEngineer = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/FieldEngineers.lua').RegularAIEngineer

ConstructionUnit = RegularAIEngineer(ConstructionUnit)

UAL0208 = Class(ConstructionUnit) {}

TypeClass = UAL0208
