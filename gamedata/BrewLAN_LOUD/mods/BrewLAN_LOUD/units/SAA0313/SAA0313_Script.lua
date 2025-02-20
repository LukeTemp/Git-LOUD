--------------------------------------------------------------------------------
local AAirUnit = import('/lua/defaultunits.lua').AirUnit

local MissileFlare = import('/lua/defaultunits.lua').BaseDirectionalAntiMissileFlare
--------------------------------------------------------------------------------
local ADFPhasonLaser = import('/lua/aeonweapons.lua').ADFPhasonLaser
--------------------------------------------------------------------------------
SAA0313 = Class(AAirUnit, MissileFlare) {
    Weapons = {
        AAGun = Class(ADFPhasonLaser) {}
    },

    FlareBones = {
        'Contrail_RI',
        'Contrail_LI'
    },

    OnStopBeingBuilt = function(self,builder,layer)
        AAirUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_StealthToggle', true)
        self:CreateMissileDetector()
		self:DisableUnitIntel('Cloak')
        self:RequestRefreshUI()
    end,

    OnLayerChange = function(self, new, old)
        AAirUnit.OnLayerChange(self, new, old)
        if new == 'Land' then
            self:EnableUnitIntel('Cloak')
        else
		    self:DisableUnitIntel('Cloak')
        end
    end,
}

TypeClass = SAA0313
