local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local AeonBuffField = import('/lua/aeonweapons.lua').AeonBuffField

local Buff = import('/lua/sim/Buff.lua')

local AWeapons = import('/lua/aeonweapons.lua')

local AIFCommanderDeathWeapon = AWeapons.AIFCommanderDeathWeapon
local ADFDisruptorCannonWeapon = AWeapons.ADFDisruptorCannonWeapon
local ADFChronoDampener = AWeapons.ADFChronoDampener
local AANChronoTorpedoWeapon = AWeapons.AANChronoTorpedoWeapon
local AIFArtilleryMiasmaShellWeapon = AWeapons.AIFArtilleryMiasmaShellWeapon
local AeonACUPhasonLaser = AWeapons.ADFPhasonLaser
local AIFQuasarAntiTorpedoWeapon = AWeapons.AIFQuasarAntiTorpedoWeapon
local AAMWillOWisp = AWeapons.AAMWillOWisp
local ADFOverchargeWeapon = AWeapons.ADFOverchargeWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')

local CreateAeonCommanderBuildingEffects = EffectUtil.CreateAeonCommanderBuildingEffects

local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local Weapon = import('/lua/sim/Weapon.lua').Weapon

local EXCEMPArrayBeam01 = import('/mods/BlackOpsACUs/lua/EXBlackOpsweapons.lua').EXCEMPArrayBeam01


EAL0001 = Class(AWalkingLandUnit) {

    DeathThreadDestructionWaitTime = 2,
	
	BuffFields = {
	
		DamageField1 = Class(AeonBuffField){
		
			OnCreate = function(self)
				AeonBuffField.OnCreate(self)
			end,
		},
		
		DamageField2 = Class(AeonBuffField){
		
			OnCreate = function(self)
				AeonBuffField.OnCreate(self)
			end,
		},
		
		DamageField3 = Class(AeonBuffField){
		
			OnCreate = function(self)
				AeonBuffField.OnCreate(self)
			end,
		},
	},

    Weapons = {
	
        DeathWeapon = Class(AIFCommanderDeathWeapon) {},
		
        EXTargetPainter = Class(EXCEMPArrayBeam01) {},
		
        RightDisruptor = Class(ADFDisruptorCannonWeapon) {},
		
        OverCharge = Class(ADFOverchargeWeapon) {

            OnCreate = function(self)
                ADFOverchargeWeapon.OnCreate(self)
                self:SetWeaponEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
				self.unit:SetOverchargePaused(false)
            end,

            OnEnableWeapon = function(self)
                if self:BeenDestroyed() then return end
                ADFOverchargeWeapon.OnEnableWeapon(self)
                self:SetWeaponEnabled(true)
                self.unit:SetWeaponEnabledByLabel('RightDisruptor', false)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(true)
                self.AimControl:SetPrecedence(20)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.AimControl:SetHeadingPitch( self.unit:GetWeaponManipulatorByLabel('RightDisruptor'):GetHeadingPitch() )
            end,

            OnWeaponFired = function(self)
                ADFOverchargeWeapon.OnWeaponFired(self)
                self:OnDisableWeapon()
                self:ForkThread(self.PauseOvercharge)
            end,
            
            OnDisableWeapon = function(self)
                if self.unit:BeenDestroyed() then return end
                self:SetWeaponEnabled(false)
                self.unit:SetWeaponEnabledByLabel('RightDisruptor', true)
                self.unit:BuildManipulatorSetEnabled(false)
                self.AimControl:SetEnabled(false)
                self.AimControl:SetPrecedence(0)
                self.unit.BuildArmManipulator:SetPrecedence(0)
                self.unit:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.AimControl:GetHeadingPitch() )
            end,
            
            PauseOvercharge = function(self)
                if not self.unit:IsOverchargePaused() then
                    self.unit:SetOverchargePaused(true)
                    WaitSeconds(1/self:GetBlueprint().RateOfFire)
                    self.unit:SetOverchargePaused(false)
                end
            end,
            
            OnFire = function(self)
                if not self.unit:IsOverchargePaused() then
                    ADFOverchargeWeapon.OnFire(self)
                end
            end,
			
            IdleState = State(ADFOverchargeWeapon.IdleState) {
			
                OnGotTarget = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ADFOverchargeWeapon.IdleState.OnGotTarget(self)
                    end
                end,            
				
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ChangeState(self, self.RackSalvoFiringState)
                    end
                end,
				
            },
			
            RackSalvoFireReadyState = State(ADFOverchargeWeapon.RackSalvoFireReadyState) {
                OnFire = function(self)
                    if not self.unit:IsOverchargePaused() then
                        ADFOverchargeWeapon.RackSalvoFireReadyState.OnFire(self)
                    end
                end,
            },              
        },
		
        EXChronoDampener01 = Class(ADFChronoDampener) {},
        EXChronoDampener02 = Class(ADFChronoDampener) {},
		
        EXTorpedoLauncher01 = Class(AANChronoTorpedoWeapon) {},
        EXTorpedoLauncher02 = Class(AANChronoTorpedoWeapon) {},
        EXTorpedoLauncher03 = Class(AANChronoTorpedoWeapon) {},
		
        EXMiasmaArtillery01 = Class(AIFArtilleryMiasmaShellWeapon) {},
        EXMiasmaArtillery02 = Class(AIFArtilleryMiasmaShellWeapon) {},
        EXMiasmaArtillery03 = Class(AIFArtilleryMiasmaShellWeapon) {},
		
        EXPhasonBeam01 = Class(AeonACUPhasonLaser) {},
        EXPhasonBeam02 = Class(AeonACUPhasonLaser) {},
        EXPhasonBeam03 = Class(AeonACUPhasonLaser) {},

        EXAntiTorpedo = Class(AIFQuasarAntiTorpedoWeapon) {},
		
        EXAntiMissile = Class(AAMWillOWisp) {},
		
    },

    OnCreate = function(self)
	
        AWalkingLandUnit.OnCreate(self)
		
        self:SetCapturable(false)
        self:SetupBuildBones()
		
        -- Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )
        
        self.RemoteViewingData = {}
        self.RemoteViewingData.RemoteViewingFunctions = {}
        self.RemoteViewingData.DisableCounter = 0
        self.RemoteViewingData.IntelButton = true
        
    end,

    GiveInitialResources = function(self)
    
        WaitTicks(2)
        self:GetAIBrain():GiveResource('Energy', self:GetBlueprint().Economy.StorageEnergy)
        self:GetAIBrain():GiveResource('Mass', self:GetBlueprint().Economy.StorageMass)
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        CreateAeonCommanderBuildingEffects( self, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,  

    OnPrepareArmToBuild = function(self)

        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
        self.wcBuildMode = true
		self:ForkThread(self.WeaponConfigCheck)
        self.BuildArmManipulator:SetHeadingPitch( self:GetWeaponManipulatorByLabel('RightDisruptor'):GetHeadingPitch() )
    end,

    OnFailedToBuild = function(self)
    
        AWalkingLandUnit.OnFailedToBuild(self)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
    
        AWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true     
    end,
    
    OnStopBuild = function(self, unitBeingBuilt)
        
        for _, emit in self.BuildEmitters do
            emit:ScaleEmitter( 0.01 )
        end
    
        if self.BuildProjectile then
        
            if self.BuildProjectile.Detached then
            
                self.BuildProjectile:AttachTo( self, self.BuildPoint )
            end
            
            self.BuildProjectile.Detached = false
        end
        
        AWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        
        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    OnStopCapture = function(self, target)
    
        AWalkingLandUnit.OnStopCapture(self, target)

        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnFailedCapture = function(self, target)
    
        AWalkingLandUnit.OnFailedCapture(self, target)

        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopReclaim = function(self, target)
    
        AWalkingLandUnit.OnStopReclaim(self, target)

        if self.Dead then return end
        
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.wcBuildMode = false
		self:ForkThread(self.WeaponConfigCheck)
        self:GetWeaponManipulatorByLabel('RightDisruptor'):SetHeadingPitch( self.BuildArmManipulator:GetHeadingPitch() )
    end,

    OnStopBeingBuilt = function(self,builder,layer)
	
        AWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)

		self:DisableUnitIntel('CloakField')
        self:DisableUnitIntel('Cloak')		

        --self:DisableUnitIntel('RadarStealth')
        --self:DisableUnitIntel('SonarStealth')
		
		self:HideBone('Engineering', true)
		self:HideBone('Combat_Engineering', true)
		self:HideBone('Left_Turret_Plates', true)
		self:HideBone('Basic_GunUp_Range', true)
		self:HideBone('Basic_GunUp_RoF', true)
		self:HideBone('Torpedo_Launcher', true)
		self:HideBone('Laser_Cannon', true)
		self:HideBone('IntelPack_Torso', true)
		self:HideBone('IntelPack_Head', true)
		self:HideBone('IntelPack_LShoulder', true)
		self:HideBone('IntelPack_RShoulder', true)
		self:HideBone('DamagePack_LArm', true)
		self:HideBone('DamagePack_RArm', true)
		self:HideBone('DamagePack_Torso', true)
		self:HideBone('DamagePack_RLeg_B01', true)
		self:HideBone('DamagePack_RLeg_B02', true)
		self:HideBone('DamagePack_LLeg_B01', true)
		self:HideBone('DamagePack_LLeg_B02', true)
		self:HideBone('ShieldPack_Normal', true)
		self:HideBone('Shoulder_Arty_L', true)
		self:HideBone('ShieldPack_Arty_LArm', true)
		self:HideBone('Shoulder_Arty_R', true)
		self:HideBone('ShieldPack_Arty_RArm', true)
		self:HideBone('Artillery_Torso', true)
		self:HideBone('ShieldPack_Artillery', true)
		self:HideBone('Artillery_Barrel_Left', true)
		self:HideBone('Artillery_Barrel_Right', true)
		self:HideBone('Artillery_Pitch', true)
		
		self:SetWeaponEnabledByLabel('EXAntiMissile', false)
		
		self.ccShield = false
		self.ccArtillery = false
		self.wcBuildMode = false
		self.wcOCMode = false
		self.wcChrono01 = false
		self.wcChrono02 = false
		self.wcTorp01 = false
		self.wcTorp02 = false
		self.wcTorp03 = false
		self.wcArtillery01 = false
		self.wcArtillery02 = false
		self.wcArtillery03 = false
		self.wcBeam01 = false
		self.wcBeam02 = false
		self.wcBeam03 = false
		self.wcMaelstrom01 = false
		self.wcMaelstrom02 = false
		self.wcMaelstrom03 = false
		
		local wepPainter = self:GetWeaponByLabel('EXTargetPainter')
		wepPainter:ChangeMaxRadius(100)
		
		self:ForkThread(self.WeaponConfigCheck)
		self:ForkThread(self.WeaponRangeReset)
		
		self.MaelstromEffects01 = {}
		
        self:ForkThread(self.GiveInitialResources)
		
        self.ShieldEffectsBag = {}
		
		self.RBImpEngineering = false
		self.RBAdvEngineering = false
		self.RBExpEngineering = false
		
		self.RBComEngineering = false
		self.RBAssEngineering = false
		self.RBApoEngineering = false
		
		self.RBDefTier1 = false
		self.RBDefTier2 = false
		self.RBDefTier3 = false
		
		self.RBComTier1 = false
		self.RBComTier2 = false
		self.RBComTier3 = false
		
		self.RBIntTier1 = false
		self.RBIntTier2 = false
		self.RBIntTier3 = false
		
		self.ScryActive = false
		self.regenamount = 0
		
        self.Sync.Abilities = self:GetBlueprint().Abilities
        
        self.Sync.Abilities.TargetLocation.Active = false
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
    
        AWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
        
        if self.RemoteViewingData.Satellite then
            self.RemoteViewingData.Satellite:DisableIntel('Vision')
            self.RemoteViewingData.Satellite:Destroy()
        end
    end,

    EXRemoteCheck = function(self)
    
        if self.RBIntTier2 and self.ScryActive then
        
			self:DisableRemoteViewingButtons()
            
			WaitSeconds(10)
            
			if self.RBIntTier2 then
				self:EnableRemoteViewingButtons()
			end
		end
    end,

    DisableRemoteViewingButtons = function(self)
    
        self.Sync.Abilities.TargetLocation.Active = false

        self:RemoveToggleCap('RULEUTC_IntelToggle')
    end,

    EnableRemoteViewingButtons = function(self)

        self.Sync.Abilities.TargetLocation.Active = true

        self:AddToggleCap('RULEUTC_IntelToggle')
    end,

    OnTargetLocation = function(self, location)

        if self.RemoteViewingData.IntelButton then
			
            -- Initial energy drain here - we drain resources instantly when an eye is relocated (including initial move)
            local aiBrain = self:GetAIBrain()
            local drain = self:GetBlueprint().Economy.InitialRemoteViewingEnergyDrain

			if not ( aiBrain:GetEconomyStored('ENERGY') > drain ) then
				FloatingEntityText( self.Sync.id, "Insufficient Energy Storage")
				return
			end
            
			-- Drain economy here
			aiBrain:TakeResource( 'ENERGY', drain )

			self.RemoteViewingData.VisibleLocation = location
			self:CreateVisibleEntity()
		end
    end,

    CreateVisibleEntity = function(self)
		
		local VisibilityEntityWillBeCreated = (self.RemoteViewingData.VisibleLocation and self.RemoteViewingData.DisableCounter == 0 and self.RemoteViewingData.IntelButton)

        -- Only give a visible area if we have a location and intel button enabled
        if not self.RemoteViewingData.VisibleLocation then
            self:SetMaintenanceConsumptionInactive()
            return
        end

		--LOG("*AI DEBUG Checking for AntiRemoteViewing")

		for num, brain in ArmyBrains do
		
			local unitList = brain:GetListOfUnits(categories.ANTITELEPORT, false)
			local location = self.RemoteViewingData.VisibleLocation
			
			for i, unit in unitList do

				--	if it's an ally, then we skip.
				if not IsEnemy(self.Sync.army, unit.Sync.army) then 
					continue
				end
				
				local noTeleDistance = unit:GetBlueprint().Defense.NoTeleDistance
				local atposition = unit:GetPosition()

				local targetdestdistance = VDist2(location[1], location[3], atposition[1], atposition[3])

				-- if the antiteleport range covers the targetlocation
				if noTeleDistance and noTeleDistance > targetdestdistance then

					FloatingEntityText(self.Sync.id,'Remote Viewing Destination Scrambled')

					self.RemoteViewingData.VisibleLocation = false

					-- play audio warning
					if GetFocusArmy() == self.Sync.army then
						local Voice = Sound {Bank = 'XGG', Cue = 'XGG_Computer_CV01_04765',}
						local Brain = self:GetAIBrain()

						ForkThread(Brain.PlayVOSound, Brain, Voice, 'RemoteViewingFailed')
					end						

					return
				end
			end
		end			

        if self.RemoteViewingData.VisibleLocation and self.RemoteViewingData.DisableCounter == 0 and self.RemoteViewingData.IntelButton then
			
            local bp = self:GetBlueprint()

            self:SetMaintenanceConsumptionActive()

            -- Create new visible area
            if not self.RemoteViewingData.Satellite then

                local spec = {
                    X = self.RemoteViewingData.VisibleLocation[1],
                    Z = self.RemoteViewingData.VisibleLocation[3],
                    Radius = bp.Intel.RemoteViewingRadius,
                    LifeTime = -1,
                    Omni = false,
                    Radar = false,
                    Vision = true,
                    Army = self:GetAIBrain():GetArmyIndex(),
                }

                self.RemoteViewingData.Satellite = VizMarker(spec)
                self.Trash:Add(self.RemoteViewingData.Satellite)

            else

                -- Move and reactivate old visible area
                if not self.RemoteViewingData.Satellite:BeenDestroyed() then
                    Warp( self.RemoteViewingData.Satellite, self.RemoteViewingData.VisibleLocation )
                    self.RemoteViewingData.Satellite:EnableIntel('Vision')
                end
            end

            -- monitor resources
            if self.RemoteViewingData.ResourceThread then
                self.RemoteViewingData.ResourceThread:Destroy()
            end

            self.RemoteViewingData.ResourceThread = self:ForkThread(self.DisableResourceMonitor)
        end

        if VisibilityEntityWillBeCreated then
			
            local bp = self:GetBlueprint().Intel

            -- start the cooldown period before allowing target to be moved again
            if bp.Cooldown and bp.Cooldown > 0 then
                self.CooldownThread = self:ForkThread(self.Cooldown, bp.Cooldown)
                self.Trash:Add(self.CooldownThread)
            end

			-- start the timer that will auto-shut off the eye
            if bp.Viewtime and bp.Viewtime > 0 then
                self.ViewtimeThread = self:ForkThread(self.Viewtime, bp.Viewtime)
                self.Trash:Add(self.ViewtimeThread)
            end

			-- grow the viewing radius in steps
            if bp.RemoteViewingRadiusFinal and bp.RemoteViewingRadiusFinal > 0 and bp.RemoteViewingRadiusFinal != bp.RemoteViewingRadius then
				
                -- for a growing viewing radius
                local initRadius = bp.RemoteViewingRadius
                local finalRadius = bp.RemoteViewingRadiusFinal
                local step = bp.RadiusGrowStepSize or 0.2

                self.ViewingRadiusThread = self:ForkThread(self.ViewingRadius, initRadius, finalRadius, step)
                self.Trash:Add(self.ViewingRadiusThread)
            end
        end
    end,

    DisableVisibleEntity = function(self)

        -- if visible entity already off
        if self.RemoteViewingData.DisableCounter > 1 then
            return
        end

        -- disable vis entity and monitor resources
        if not self:IsDead() and self.RemoteViewingData.Satellite then

            self.RemoteViewingData.Satellite:DisableIntel('Vision')
            self:SetMaintenanceConsumptionInactive() #-- remove power consumption while off            
        end

        -- kill any thread that isn't used anymore
        if self.ViewtimeThread then
            KillThread(self.ViewtimeThread)
        end

        if self.ViewingRadiusThread then
            KillThread(self.ViewingRadiusThread)
        end
    end,
    
--[[
    CreateVisibleEntity = function(self)
	
        -- Only give a visible area if we have a location and intel button enabled
        if not self.RemoteViewingData.VisibleLocation then
            return
        end

        if self.RemoteViewingData.VisibleLocation and self.RemoteViewingData.DisableCounter == 0 and self.RemoteViewingData.IntelButton then
        
            local bp = __blueprints[self.BlueprintID]
            
            -- Create new visible area
            if not self.RemoteViewingData.Satellite then
            
                local spec = {
                    X = self.RemoteViewingData.VisibleLocation[1],
                    Z = self.RemoteViewingData.VisibleLocation[3],
                    Radius = bp.Intel.RemoteViewingRadius,
                    LifeTime = -1,
                    Omni = false,
                    Radar = false,
                    Vision = true,
                    Army = self:GetAIBrain():GetArmyIndex(),
                }
                
                self.RemoteViewingData.Satellite = VizMarker(spec)
                self.Trash:Add(self.RemoteViewingData.Satellite)
            else
                -- Move and reactivate old visible area
                if not self.RemoteViewingData.Satellite:BeenDestroyed() then
                    Warp( self.RemoteViewingData.Satellite, self.RemoteViewingData.VisibleLocation )
                    self.RemoteViewingData.Satellite:EnableIntel('Vision')
                end
            end
			self:ForkThread(self.DisableVisibleEntity)
        end
    end,

    DisableVisibleEntity = function(self)
	
        -- visible entity already off
		WaitSeconds(5)
		
        if self.RemoteViewingData.DisableCounter > 1 then return end
		
        -- disable vis entity and monitor resources
        if not self:IsDead() and self.RemoteViewingData.Satellite then
            self.RemoteViewingData.Satellite:DisableIntel('Vision')
        end
    end,
--]]

    DisableResourceMonitor = function(self)

        WaitTicks( 5 )

        local fraction = self:GetResourceConsumed()

        while fraction == 1 do
            WaitTicks( 5 )
            fraction = self:GetResourceConsumed()
        end

        if self.RemoteViewingData.IntelButton then
            self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter + 1
            self.RemoteViewingData.ResourceThread = self:ForkThread(self.EnableResourceMonitor)
            self:DisableVisibleEntity()
        end
    end,

    EnableResourceMonitor = function(self)

        local recharge = self:GetBlueprint().Intel.ReactivateTime or 10

        WaitTicks( recharge * 10 )

        self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter - 1

        self:CreateVisibleEntity()
    end,

	-- a cooldown period. the vision marker cannot be changed during this period
    Cooldown = function(self, time)

        if time > 0 then

            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = false

            self:RemoveToggleCap('RULEUTC_IntelToggle')

            WaitTicks(time * 10)

            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = true

            self:AddToggleCap('RULEUTC_IntelToggle')
        end
    end,
		
    -- an auto disable feature. removes the view after a set period
    Viewtime = function(self, viewtime)

        if viewtime > 0 then
            WaitTicks(viewtime * 10)
            self:DisableVisibleEntity()
        end
    end,

    -- changes the size of the camera each tick. Should be able to handle growing and shrinking
    ViewingRadius = function(self, initialRadius, endingRadius, step)
		
        local LOUDCEIL = math.ceil
		local LOUDMIN = math.min

        local sat = self.RemoteViewingData.Satellite
        local nTicks = LOUDCEIL( (endingRadius - initialRadius) / step )

        if initialRadius > endingRadius then
            step = LOUDMIN( step, -step)  -- make sure we get a negative stepsize
            nTicks = -nTicks
        end

        sat:SetIntelRadius('vision', initialRadius)

        local curRadius = initialRadius

        for i=1, nTicks do

            WaitTicks(1)

            if not sat or sat:BeenDestroyed() then return end
    
            curRadius = curRadius + step
            sat:SetIntelRadius('vision', curRadius)
        end

        sat:SetIntelRadius('vision', endingRadius)
    end,
    
    PlayCommanderWarpInEffect = function(self)
    
        self:HideBone(0, true)
        self:SetUnSelectable(true)
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)
        self:ForkThread(self.WarpInEffectThread)
    end,

    WarpInEffectThread = function(self)
    
        self:PlayUnitSound('CommanderArrival')
        self:CreateProjectile( '/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
        WaitSeconds(2.1)
        self:SetMesh('/mods/BlackopsACUs/units/eal0001/EAL0001_PhaseShield_mesh', true)
        self:ShowBone(0, true)
		self:HideBone('Engineering', true)
		self:HideBone('Combat_Engineering', true)
		self:HideBone('Left_Turret_Plates', true)
		self:HideBone('Basic_GunUp_Range', true)
		self:HideBone('Basic_GunUp_RoF', true)
		self:HideBone('Torpedo_Launcher', true)
		self:HideBone('Laser_Cannon', true)
		self:HideBone('IntelPack_Torso', true)
		self:HideBone('IntelPack_Head', true)
		self:HideBone('IntelPack_LShoulder', true)
		self:HideBone('IntelPack_RShoulder', true)
		self:HideBone('DamagePack_LArm', true)
		self:HideBone('DamagePack_RArm', true)
		self:HideBone('DamagePack_Torso', true)
		self:HideBone('DamagePack_RLeg_B01', true)
		self:HideBone('DamagePack_RLeg_B02', true)
		self:HideBone('DamagePack_LLeg_B01', true)
		self:HideBone('DamagePack_LLeg_B02', true)
		self:HideBone('ShieldPack_Normal', true)
		self:HideBone('Shoulder_Arty_L', true)
		self:HideBone('ShieldPack_Arty_LArm', true)
		self:HideBone('Shoulder_Arty_R', true)
		self:HideBone('ShieldPack_Arty_RArm', true)
		self:HideBone('Artillery_Torso', true)
		self:HideBone('ShieldPack_Artillery', true)
		self:HideBone('Artillery_Barrel_Left', true)
		self:HideBone('Artillery_Barrel_Right', true)
		self:HideBone('Artillery_Pitch', true)
        self:SetUnSelectable(false)
        self:SetBusy(false)        
        self:SetBlockCommandQueue(false)
        local totalBones = self:GetBoneCount() - 1
        local army = self:GetArmy()
        for k, v in EffectTemplate.UnitTeleportSteam01 do
            for bone = 1, totalBones do
                CreateAttachedEmitter(self,bone,army, v)
            end
        end

        WaitSeconds(6)
        self:SetMesh(self:GetBlueprint().Display.MeshBlueprint, true)
    end,

    WeaponRangeReset = function(self)
    
		local wpTarget = self:GetWeaponByLabel('EXTargetPainter')
        
		wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
        
		if not self.wcChrono01 then
			local wepFlamer01 = self:GetWeaponByLabel('EXChronoDampener01')
			wepFlamer01:ChangeMaxRadius(1)
		end
		if not self.wcChrono02 then
			local wepFlamer02 = self:GetWeaponByLabel('EXChronoDampener02')
			wepFlamer02:ChangeMaxRadius(1)
		end

		if not self.wcTorp01 then
			local wepTorpedo01 = self:GetWeaponByLabel('EXTorpedoLauncher01')
			wepTorpedo01:ChangeMaxRadius(1)
		end
		if not self.wcTorp02 then
			local wepTorpedo02 = self:GetWeaponByLabel('EXTorpedoLauncher02')
			wepTorpedo02:ChangeMaxRadius(1)
		end
		if not self.wcTorp03 then
			local wepTorpedo03 = self:GetWeaponByLabel('EXTorpedoLauncher03')
			wepTorpedo03:ChangeMaxRadius(1)
		end

		if not self.wcArtillery01 then
			local wepAntiMatter01 = self:GetWeaponByLabel('EXMiasmaArtillery01')
			wepAntiMatter01:ChangeMaxRadius(1)
		end
		if not self.wcArtillery02 then
			local wepAntiMatter02 = self:GetWeaponByLabel('EXMiasmaArtillery02')
			wepAntiMatter02:ChangeMaxRadius(1)
		end
		if not self.wcArtillery03 then
			local wepAntiMatter03 = self:GetWeaponByLabel('EXMiasmaArtillery03')
			wepAntiMatter03:ChangeMaxRadius(1)
		end
        
		if not self.wcBeam01 then
			local wepGattling01 = self:GetWeaponByLabel('EXPhasonBeam01')
			wepGattling01:ChangeMaxRadius(1)
		end
		if not self.wcBeam02 then
			local wepGattling02 = self:GetWeaponByLabel('EXPhasonBeam02')
			wepGattling02:ChangeMaxRadius(1)
		end
		if not self.wcBeam03 then
			local wepGattling03 = self:GetWeaponByLabel('EXPhasonBeam03')
			wepGattling03:ChangeMaxRadius(1)
		end

    end,
	
    WeaponConfigCheck = function(self)
		
		if self.wcBuildMode then
		
			self:SetWeaponEnabledByLabel('EXTargetPainter', false)
			self:SetWeaponEnabledByLabel('RightDisruptor', false)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			self:SetWeaponEnabledByLabel('EXChronoDampener01', false)
			self:SetWeaponEnabledByLabel('EXChronoDampener02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam01', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam02', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam03', false)
		end
		
		if self.wcOCMode then
		
			self:SetWeaponEnabledByLabel('EXTargetPainter', false)
			self:SetWeaponEnabledByLabel('RightDisruptor', false)
			self:SetWeaponEnabledByLabel('EXChronoDampener01', false)
			self:SetWeaponEnabledByLabel('EXChronoDampener02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
			self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam01', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam02', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam03', false)
		end
        
		local wpTarget = self:GetWeaponByLabel('EXTargetPainter')
        local wep
        
		if not self.wcBuildMode and not self.wcOCMode then
		
			self:SetWeaponEnabledByLabel('EXTargetPainter', true)
			self:SetWeaponEnabledByLabel('RightDisruptor', true)
			
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery01', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery02', false)
			self:SetWeaponEnabledByLabel('EXMiasmaArtillery03', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam01', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam02', false)
			self:SetWeaponEnabledByLabel('EXPhasonBeam03', false)
			self:SetWeaponEnabledByLabel('OverCharge', false)
			
			if self.wcChrono01 then
			
				self:SetWeaponEnabledByLabel('EXChronoDampener01', true)
				
				wep = self:GetWeaponByLabel('EXChronoDampener01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[5].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXChronoDampener01', false)
			end
			
			
			if self.wcChrono02 then
			
				self:SetWeaponEnabledByLabel('EXChronoDampener02', true)
				
				wep = self:GetWeaponByLabel('EXChronoDampener02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[6].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXChronoDampener02', false)
			end
			
			if self.wcTorp01 then
			
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', true)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', true)
				
				wep = self:GetWeaponByLabel('EXTorpedoLauncher01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[7].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher01', false)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', false)
			end
			
			if self.wcTorp02 then
			
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', true)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', true)
				
				wep = self:GetWeaponByLabel('EXTorpedoLauncher02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[8].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher02', false)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', false)
			end
			
			if self.wcTorp03 then
			
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', true)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', true)
				
				wep = self:GetWeaponByLabel('EXTorpedoLauncher03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[9].MaxRadius)

			else
				self:SetWeaponEnabledByLabel('EXTorpedoLauncher03', false)
				self:SetWeaponEnabledByLabel('EXAntiTorpedo', false)
			end
			
			if self.wcArtillery01 then
			
				self:SetWeaponEnabledByLabel('EXMiasmaArtillery01', true)
				
				wep = self:GetWeaponByLabel('EXMiasmaArtillery01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[10].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[10].MaxRadius)
			end
			
			if self.wcArtillery02 then
			
				self:SetWeaponEnabledByLabel('EXMiasmaArtillery02', true)
				
				wep = self:GetWeaponByLabel('EXMiasmaArtillery02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[11].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[11].MaxRadius)
			end
			
			if self.wcArtillery03 then
			
				self:SetWeaponEnabledByLabel('EXMiasmaArtillery03', true)
				
				wep = self:GetWeaponByLabel('EXMiasmaArtillery03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[12].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[12].MaxRadius)
			end
			
			if self.wcBeam01 then
			
				self:SetWeaponEnabledByLabel('EXPhasonBeam01', true)
       			self:SetWeaponEnabledByLabel('RightDisruptor', false)
			
				wep = self:GetWeaponByLabel('EXPhasonBeam01')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[13].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[13].MaxRadius)
			end
			
			if self.wcBeam02 then
			
				self:SetWeaponEnabledByLabel('EXPhasonBeam02', true)
                
				wep = self:GetWeaponByLabel('EXPhasonBeam02')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[14].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[14].MaxRadius)
			end
			
			if self.wcBeam03 then
			
				self:SetWeaponEnabledByLabel('EXPhasonBeam03', true)
                
				wep = self:GetWeaponByLabel('EXPhasonBeam03')
				wep:ChangeMaxRadius(self:GetBlueprint().Weapon[15].MaxRadius)

				wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[15].MaxRadius)
			end
			
			if self.wcMaelstrom01 then

				self:GetBuffFieldByName('AeonMaelstromBuffField'):Enable()
                
                self.MaelstromFieldName = 'AeonMaelstromBuffField'

                self:EnableUnitIntel('RadarStealthField')
                self:SetIntelRadius('RadarStealth', 24 )

			else
				self:GetBuffFieldByName('AeonMaelstromBuffField'):Disable()
			end
			
			if self.wcMaelstrom02 then

				self:GetBuffFieldByName('AeonMaelstromBuffField2'):Enable()

                self.MaelstromFieldName = 'AeonMaelstromBuffField2'

                self:EnableUnitIntel('RadarStealthField')
                self:SetIntelRadius('RadarStealth', 32 )

			else
				self:GetBuffFieldByName('AeonMaelstromBuffField2'):Disable()
			end
			
			if self.wcMaelstrom03 then

				self:GetBuffFieldByName('AeonMaelstromBuffField3'):Enable()

                self.MaelstromFieldName = 'AeonMaelstromBuffField3'

                self:EnableUnitIntel('RadarStealthField')
                self:SetIntelRadius('RadarStealth', 40 )

			else
				self:GetBuffFieldByName('AeonMaelstromBuffField3'):Disable()
			end
            
            if not self.wcMaelstrom01 and not self.wcMaelstrom02 and not self.wcMaelstrom03 then

                self.MaelstromFieldName = false

                self:SetIntelRadius('RadarStealth', 1 )
                self:DisableUnitIntel('RadarStealthField')
            end
		end
    end,
	
    ArtyShieldCheck = function(self)
	
		if self.ccArtillery and not self.ccShield then
		
			self:HideBone('ShieldPack_Normal', true)
			self:HideBone('Shoulder_Normal_L', true)
			self:HideBone('Shoulder_Normal_R', true)
			self:ShowBone('Shoulder_Arty_L', true)
			self:ShowBone('Shoulder_Arty_R', true)
			self:ShowBone('Artillery_Torso', true)
			self:ShowBone('Artillery_Barrel_Left', true)
			self:ShowBone('Artillery_Barrel_Right', true)
			self:HideBone('ShieldPack_Arty_LArm', true)
			self:HideBone('ShieldPack_Arty_RArm', true)
			self:HideBone('ShieldPack_Artillery', true)
			self:ShowBone('Artillery_Pitch', true)
			
		elseif self.ccShield and not self.ccArtillery then
		
			self:ShowBone('ShieldPack_Normal', true)
			self:ShowBone('Shoulder_Normal_L', true)
			self:ShowBone('Shoulder_Normal_R', true)
			self:HideBone('Shoulder_Arty_L', true)
			self:HideBone('Shoulder_Arty_R', true)
			self:HideBone('Artillery_Torso', true)
			self:HideBone('Artillery_Barrel_Left', true)
			self:HideBone('Artillery_Barrel_Right', true)
			self:HideBone('ShieldPack_Arty_LArm', true)
			self:HideBone('ShieldPack_Arty_RArm', true)
			self:HideBone('ShieldPack_Artillery', true)
			self:HideBone('Artillery_Pitch', true)
			
		elseif self.ccArtillery and self.ccShield then
		
			self:HideBone('ShieldPack_Normal', true)
			self:HideBone('Shoulder_Normal_L', true)
			self:HideBone('Shoulder_Normal_R', true)
			self:ShowBone('Shoulder_Arty_L', true)
			self:ShowBone('Shoulder_Arty_R', true)
			self:ShowBone('Artillery_Torso', true)
			self:ShowBone('Artillery_Barrel_Left', true)
			self:ShowBone('Artillery_Barrel_Right', true)
			self:ShowBone('ShieldPack_Arty_LArm', true)
			self:ShowBone('ShieldPack_Arty_RArm', true)
			self:ShowBone('ShieldPack_Artillery', true)
			self:ShowBone('Artillery_Pitch', true)
			
		elseif not self.ccArtillery and not self.ccShield then
		
			self:HideBone('ShieldPack_Normal', true)
			self:ShowBone('Shoulder_Normal_L', true)
			self:ShowBone('Shoulder_Normal_R', true)
			self:HideBone('Shoulder_Arty_L', true)
			self:HideBone('Shoulder_Arty_R', true)
			self:HideBone('Artillery_Torso', true)
			self:HideBone('Artillery_Barrel_Left', true)
			self:HideBone('Artillery_Barrel_Right', true)
			self:HideBone('ShieldPack_Arty_LArm', true)
			self:HideBone('ShieldPack_Arty_RArm', true)
			self:HideBone('ShieldPack_Artillery', true)
			self:HideBone('Artillery_Pitch', true)
		end
    end,

    OnTransportDetach = function(self, attachBone, unit)

        AWalkingLandUnit.OnTransportDetach(self, attachBone, unit)

		self:StopSiloBuild()
        self:ForkThread(self.WeaponConfigCheck)
    end,

    OnScriptBitClear = function(self, bit)

        if bit == 0 then        -- shield

			self:DisableShield()
			self:StopUnitAmbientSound( 'ActiveLoop' )
            
        elseif bit == 3 then    -- Rhianne Optics
        
            self:SetMaintenanceConsumptionActive()

        elseif bit == 5 then    -- Standard Intel
        
            self:SetMaintenanceConsumptionActive()

            self:EnableUnitIntel('Radar')
            self:EnableUnitIntel('Sonar')
            self:EnableUnitIntel('Omni')
            
        elseif bit == 7 then    -- Maelstrom Field

            if self.MaelstromFieldName then
                self:GetBuffFieldByName( self.MaelstromFieldName ):Enable()
            end

        end
    end,

    OnScriptBitSet = function(self, bit)

        if bit == 0 then

			self:EnableShield()
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            
        elseif bit == 3 then 

            self:SetMaintenanceConsumptionInactive()
            
        elseif bit == 5 then

            self:SetMaintenanceConsumptionInactive()

            self:DisableUnitIntel('Radar')
            self:DisableUnitIntel('Sonar')
            self:DisableUnitIntel('Omni')

        elseif bit == 7 then

            if self.MaelstromFieldName then
                self:GetBuffFieldByName( self.MaelstromFieldName ):Disable()
            end

        end
    end,

    CreateEnhancement = function(self, enh)
	
        AWalkingLandUnit.CreateEnhancement(self, enh)
		
        local bp = self:GetBlueprint().Enhancements[enh]
		
        if enh =='EXImprovedEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Imp_Eng')
			
			self.RBImpEngineering = true
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			
        elseif enh =='EXImprovedEngineeringRemove' then
			
            if Buff.HasBuff( self, 'ACU_T2_Imp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Imp_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )

			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			
        elseif enh =='EXAdvancedEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Adv_Eng')

			self.RBImpEngineering = true
			self.RBAdvEngineering = true
			self.RBExpEngineering = false
			
        elseif enh =='EXAdvancedEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Adv_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Adv_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )

			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			
        elseif enh =='EXExperimentalEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Exp_Eng')			

			self.RBImpEngineering = true
			self.RBAdvEngineering = true
			self.RBExpEngineering = true
			
		elseif enh =='EXExperimentalEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Exp_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Exp_Eng' )
            end		

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )

			self.RBImpEngineering = false
			self.RBAdvEngineering = false
			self.RBExpEngineering = false
			
        elseif enh =='EXCombatEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T2_Combat_Eng')

			self.wcChrono01 = true
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = true
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
        elseif enh =='EXCombatEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T2_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T2_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcChrono01 = false
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
        elseif enh =='EXAssaultEngineering' then
		
            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T3_Combat_Eng')

			self.wcChrono01 = false
			self.wcChrono02 = true
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = true
			self.RBAssEngineering = true
			self.RBApoEngineering = false
			
        elseif enh =='EXAssaultEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Combat_Eng' )
            end
			
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcChrono01 = false
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
        elseif enh =='EXApocalypticEngineering' then

            self:RemoveBuildRestriction(ParseEntityCategory(bp.BuildableCategoryAdds))
			
            Buff.ApplyBuff(self, 'ACU_T4_Combat_Eng')
			
			self.wcChrono01 = false
			self.wcChrono02 = true
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.RBComEngineering = true
			self.RBAssEngineering = true
			self.RBApoEngineering = true
			
        elseif enh =='EXApocalypticEngineeringRemove' then
		
            if Buff.HasBuff( self, 'ACU_T4_Combat_Eng' ) then
                Buff.RemoveBuff( self, 'ACU_T4_Combat_Eng' )
            end

            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER4COMMANDER) )

			self.wcChrono01 = false
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComEngineering = false
			self.RBAssEngineering = false
			self.RBApoEngineering = false
			
		elseif enh =='EXDisruptorrBooster' then
        
			local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            
            -- increase the damage 50%
			wepDisruptor:AddDamageMod( self:GetBlueprint().Weapon[2].Damage * .5 )
            
            -- increase radius by 5
			wepDisruptor:ChangeMaxRadius( self:GetBlueprint().Weapon[2].MaxRadius + 5)
            
            Buff.ApplyBuff(self,'MobilityPenalty')
            
			local wpTarget = self:GetWeaponByLabel('EXTargetPainter')
            
			wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
            
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            
			wepOvercharge:ChangeMaxRadius(self:GetBlueprint().Weapon[3].MaxRadius + 5)
            
			self:ShowBone('Basic_GunUp_Range', true)
			
        elseif enh =='EXDisruptorrBoosterRemove' then
        
			local wepDisruptor = self:GetWeaponByLabel('RightDisruptor')
            
            -- remove previously added damage increase
			wepDisruptor:AddDamageMod( -0.5 * self:GetBlueprint().Weapon[2].Damage )
            
            -- revert range to original value
			wepDisruptor:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end
            
			local wpTarget = self:GetWeaponByLabel('EXTargetPainter')
            
			wpTarget:ChangeMaxRadius(self:GetBlueprint().Weapon[2].MaxRadius)
            
			local wepOvercharge = self:GetWeaponByLabel('OverCharge')
            
			wepOvercharge:ChangeMaxRadius(self:GetBlueprint().Weapon[3].MaxRadius)
            
			self:HideBone('Basic_GunUp_Range', true)

        elseif enh =='EXTorpedoLauncher' then
			self.wcTorp01 = true
			self.wcTorp02 = false
			self.wcTorp03 = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

        elseif enh =='EXTorpedoLauncherRemove' then
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

		elseif enh =='EXTorpedoRapidLoader' then
			self.wcTorp01 = false
			self.wcTorp02 = true
			self.wcTorp03 = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXTorpedoRapidLoaderRemove' then
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

		elseif enh =='EXTorpedoClusterLauncher' then
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = true
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXTorpedoClusterLauncherRemove' then
			self.wcTorp01 = false
			self.wcTorp02 = false
			self.wcTorp03 = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXArtilleryMiasma' then
			self.wcArtillery01 = true
			self.wcArtillery02 = false
			self.wcArtillery03 = false
            
			self.ccArtillery = true
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)

        elseif enh =='EXArtilleryMiasmaRemove' then
			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = false
            
			self.ccArtillery = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)

        elseif enh =='EXAdvancedShells' then
			self.wcArtillery01 = false
			self.wcArtillery02 = true
			self.wcArtillery03 = false
            
			self.ccArtillery = true
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh =='EXAdvancedShellsRemove' then
			self:RemoveToggleCap('RULEUTC_WeaponToggle')
			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = false
            
			self.ccArtillery = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh =='EXImprovedReloader' then
			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = true

			self.ccArtillery = true
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh =='EXImprovedReloaderRemove' then    
			self:RemoveToggleCap('RULEUTC_WeaponToggle')

			self.wcArtillery01 = false
			self.wcArtillery02 = false
			self.wcArtillery03 = false

			self.ccArtillery = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh =='EXBeamPhason' then
			self.wcBeam01 = true
			self.wcBeam02 = false
			self.wcBeam03 = false
            
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXBeamPhasonRemove' then
			self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXImprovedCoolingSystem' then
            self.wcBeam01 = false
			self.wcBeam02 = true
			self.wcBeam03 = false

			self.wcChrono01 = true
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)    
			
        elseif enh =='EXImprovedCoolingSystemRemove' then
			self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = false

			self.wcChrono01 = false
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXPowerBooster' then
            self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')

			self.wcChrono01 = false
			self.wcChrono02 = true
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh =='EXPowerBoosterRemove' then
			self.wcBeam01 = false
			self.wcBeam02 = false
			self.wcBeam03 = false
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			self.wcChrono01 = false
			self.wcChrono02 = false
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
        elseif enh == 'EXShieldBattery' then
        
            self:AddToggleCap('RULEUTC_ShieldToggle')
			
            self:CreateShield(bp)
            
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            
			self.ccShield = true
            
			self:SetWeaponEnabledByLabel('EXAntiMissile', true)			
            
			self:ForkThread(self.ArtyShieldCheck)
			
		elseif enh == 'EXShieldBatteryRemove' then
            self:DestroyShield()
            
            RemoveUnitEnhancement(self, 'EXShieldBatteryRemove')
            
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
            
			self.ccShield = false
            
			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
            
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh == 'EXActiveShielding' then
            
            self:CreatePersonalShield(bp)
            
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            
			self.ccShield = true
            
			self:SetWeaponEnabledByLabel('EXAntiMissile', true)			
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh == 'EXActiveShieldingRemove' then
            self:DestroyShield()
            
            RemoveUnitEnhancement(self, 'EXActiveShieldingRemove')

            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
            
			self.ccShield = false

			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh == 'EXImprovedShieldBattery' then
            
            self:CreatePersonalShield(bp)
            
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            
            Buff.ApplyBuff(self,'MobilityPenalty')
            
			self.ccShield = true
            
			self:SetWeaponEnabledByLabel('EXAntiMissile', true)			
			
			self:ForkThread(self.ArtyShieldCheck)
			
        elseif enh == 'EXImprovedShieldBatteryRemove' then
            self:DestroyShield()
            
            RemoveUnitEnhancement(self, 'EXImprovedShieldBatteryRemove')

            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end
           
			self.ccShield = false

			self:SetWeaponEnabledByLabel('EXAntiMissile', false)
			
			self:ForkThread(self.ArtyShieldCheck)

			
        elseif enh == 'EXElectronicsEnhancment' then
			
            Buff.ApplyBuff(self, 'ACU_T3_Intel_Package')

            self:AddToggleCap('RULEUTC_StealthToggle')

            self:SetMaintenanceConsumptionActive()

			self:SetWeaponEnabledByLabel('EXAntiMissile', true)
            
			self.RBIntTier1 = true
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			
        elseif enh == 'EXElectronicsEnhancmentRemove' then
		
            if Buff.HasBuff( self, 'ACU_T3_Intel_Package' ) then
                Buff.RemoveBuff( self, 'ACU_T3_Intel_Package' )
            end

            self:RemoveToggleCap('RULEUTC_StealthToggle')
            
            self:SetMaintenanceConsumptionInactive()

			self:SetWeaponEnabledByLabel('EXAntiMissile', false)

			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false
			
        elseif enh == 'EXElectronicCountermeasures' then
        
            Buff.RemoveBuff( self, 'ACU_T3_Intel_Package' )
            
            self:RemoveToggleCap('RULEUTC_StealthToggle')

			self.RBIntTier1 = false
			self.RBIntTier2 = true
			self.RBIntTier3 = false

            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = true

            self:AddToggleCap('RULEUTC_IntelToggle')
			
        elseif enh == 'EXElectronicCountermeasuresRemove' then

			self:SetWeaponEnabledByLabel('EXAntiMissile', false)

			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false

            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = false

            self:RemoveToggleCap('RULEUTC_IntelToggle')			
			
        elseif enh == 'EXCloakingSubsystems' then

            self:AddCommandCap('RULEUCC_Teleport')

			self.RBIntTier1 = false
			self.RBIntTier2 = true
			self.RBIntTier3 = true
			
        elseif enh == 'EXCloakingSubsystemsRemove' then

            self:RemoveCommandCap('RULEUCC_Teleport')

			self:SetWeaponEnabledByLabel('EXAntiMissile', false)

			self.RBIntTier1 = false
			self.RBIntTier2 = false
			self.RBIntTier3 = false

            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = false

            self:RemoveToggleCap('RULEUTC_IntelToggle')

			
        elseif enh =='EXMaelstromQuantum' then

            self:AddToggleCap('RULEUTC_SpecialToggle')

			self.wcMaelstrom01 = true
			self.wcMaelstrom02 = false
			self.wcMaelstrom03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.RBComTier1 = true
			self.RBComTier2 = false
			self.RBComTier3 = false
			
        elseif enh =='EXMaelstromQuantumRemove' then
        
            self:RemoveToggleCap('RULEUTC_SpecialToggle')

			self.wcMaelstrom01 = false
			self.wcMaelstrom02 = false
			self.wcMaelstrom03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false
			
        elseif enh =='EXFieldExpander' then

			self:SetWeaponEnabledByLabel('EXAntiMissile', true)

            self.wcMaelstrom01 = false
			self.wcMaelstrom02 = true
			self.wcMaelstrom03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)    
			
			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = false
			
        elseif enh == 'EXFieldExpanderRemove' then

			self:SetWeaponEnabledByLabel('EXAntiMissile', false)

            self.wcMaelstrom01 = false
			self.wcMaelstrom02 = false
			self.wcMaelstrom03 = false

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)
			
			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false
			
        elseif enh =='EXQuantumInstability' then

			self:SetWeaponEnabledByLabel('EXAntiMissile', false)

            self.wcMaelstrom01 = false
			self.wcMaelstrom02 = false
			self.wcMaelstrom03 = true
            
            Buff.ApplyBuff(self,'MobilityPenalty')
			
			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)      
			
			self.RBComTier1 = true
			self.RBComTier2 = true
			self.RBComTier3 = true
			
        elseif enh == 'EXQuantumInstabilityRemove' then

			self:SetWeaponEnabledByLabel('EXAntiMissile', false)

            self.wcMaelstrom01 = false
			self.wcMaelstrom02 = false
			self.wcMaelstrom03 = false
            
            if Buff.HasBuff( self, 'MobilityPenalty' ) then
                Buff.RemoveBuff( self, 'MobilityPenalty' )
            end

			self:ForkThread(self.WeaponRangeReset)
			self:ForkThread(self.WeaponConfigCheck)

			self.RBComTier1 = false
			self.RBComTier2 = false
			self.RBComTier3 = false
        end
    end,

    IntelEffects = {
		Cloak = {
		    {
			    Bones = {
				    'Head',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
				    'Torso',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
			    },
			    Scale = 1.0,
			    Type = 'Cloak01',
		    },
		},
		Field = {
		    {
			    Bones = {
				    'Head',
				    'Right_Arm_B01',
				    'Left_Arm_B01',
				    'Torso',
				    'Left_Leg_B01',
				    'Left_Leg_B02',
				    'Right_Leg_B01',
				    'Right_Leg_B02',
			    },
			    Scale = 1.6,
			    Type = 'Cloak01',
		    },	
        },	
    },
	
    OnIntelEnabled = function(self)

        AWalkingLandUnit.OnIntelEnabled(self)

    end,

    OnIntelDisabled = function(self)

        AWalkingLandUnit.OnIntelDisabled(self)

    end,

    OnPaused = function(self)

        AWalkingLandUnit.OnPaused(self)

        if self.BuildingUnit then
            AWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)

        if self.BuildingUnit then
            AWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end

        AWalkingLandUnit.OnUnpaused(self)
    end,     

}

TypeClass = EAL0001