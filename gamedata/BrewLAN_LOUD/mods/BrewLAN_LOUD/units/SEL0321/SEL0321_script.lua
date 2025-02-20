local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TAMInterceptorWeapon = import('/lua/terranweapons.lua').TAMInterceptorWeapon

SEL0321 = Class(TLandUnit) {
    Weapons = {
        AntiNuke = Class(TAMInterceptorWeapon) {
        
            RackSalvoFireReadyState = State(TAMInterceptorWeapon.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    if self.unit:GetTacticalSiloAmmoCount() < 2 then
                    
                        self:ForkThread(
                            function(self)
                                WaitTicks(1)
                                if self.unit:GetTacticalSiloAmmoCount() > 1 then
                                    --Last minute panic check, not sure if it will actually work, very hard to test chance to test it
                                    TAMInterceptorWeapon.RackSalvoFireReadyState.Main(self)
                                end
                            end
                        ) 
                        return
                    else
                        TAMInterceptorWeapon.RackSalvoFireReadyState.Main(self)
                    end
                end,    
            },
        },
    },
    
}

TypeClass = SEL0321
