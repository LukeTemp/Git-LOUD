--**  File     :  /lua/defaultantimissile.lua
--**  Author(s):  Gordon Duclos
--**  Summary  :  Default definitions collision beams

local Entity = import('/lua/sim/Entity.lua').Entity

local LOUDENTITY = EntityCategoryContains
local LOUDEMITONENTITY = CreateEmitterOnEntity
local LOUDINSERT = table.insert
local LOUDPARSE = ParseEntityCategory

local LOUDSTATE = ChangeState
local WaitSeconds = WaitSeconds

local BeenDestroyed = moho.entity_methods.BeenDestroyed
local GetArmy = moho.entity_methods.GetArmy
local GetLauncher = moho.projectile_methods.GetLauncher
local SetCollisionShape = moho.entity_methods.SetCollisionShape
local SetDrawScale = moho.entity_methods.SetDrawScale

local WaitTicks = coroutine.yield

Flare = Class(Entity) {

    OnCreate = function(self, spec)

        self.Army = spec.Owner.Sync.army
        self.Owner = spec.Owner
        self.Radius = spec.Radius or 5
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, self.Radius)
        
        SetDrawScale( self, spec.Radius)
        
        self:AttachTo(spec.Owner, -1)
        self.RedirectCat = spec.Category or 'MISSILE'
		
    end,

    -- We only divert projectiles. The flare-projectile itself will be responsible for
    -- accepting the collision and causing the hostile projectile to impact.
    OnCollisionCheck = function(self,other)
	
        if LOUDENTITY(LOUDPARSE(self.RedirectCat), other) and ( self.Army != GetArmy(other)) then
            other:SetNewTarget(self.Owner)
        end
		
        return false
		
    end,
}

AAFlare = Class(Entity) {

	OnCreate = function(self, spec)

        self.Owner = spec.Owner
        self.Radius = spec.Radius or 3
        self.Army = spec.Owner.Sync.army		

        SetCollisionShape( self, 'Sphere', 0, 0, 0, self.Radius)
        
        SetDrawScale( self, spec.Radius)
		
		self.RedirectCat = categories.MISSILE * categories.ANTIAIR

	end,
	
	OnCollisionCheck = function(self,other)
		
        if LOUDENTITY(self.RedirectCat, other) and self.Army ~= GetArmy(other) and not other.Deflected then

			LOG("*AI DEBUG AAFlare Collision - New target")
			other:SetNewTarget(self.Owner)

			LOG("*AI DEBUG AAFlare Collision - New Turn")
			other:SetTurnRate(540)

			LOG("*AI DEBUG AAFlare Collision - deflected")
			other.Deflected = true

        end

		return false
	
	end,
}

DepthCharge = Class(Entity) {

    OnCreate = function(self, spec)
	
        self.Army = spec.Owner.Sync.army		    
        self.Owner = spec.Owner
        self.Radius = spec.Radius
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, self.Radius)
        
        SetDrawScale( self, spec.Radius)
        
        self:AttachTo(spec.Owner, -1)
		
    end,

    -- We only divert projectiles. The Owner will be responsible for
    -- accepting the collision and causing the hostile projectile to impact.
    OnCollisionCheck = function(self,other)
	
        if LOUDENTITY(categories.TORPEDO, other) and self.Army != GetArmy(other) then
		
			if not self.Owner.Dead then
				
				-- send enemy torpedoes at the projectile
				other:SetNewTarget(self.Owner)
				
			end
        end
		
        return false
    end,
}

MissileDetector = Class(Entity) {

    RedirectBeams = {'/effects/emitters/particle_cannon_beam_02_emit.bp'},
    EndPointEffects = {'/effects/emitters/particle_cannon_end_01_emit.bp',},

    OnCreate = function(self, spec)

		Entity.OnCreate(self, spec)

        self.Army = spec.Owner.Sync.army
		self.AttachBone = spec.AttachBone
        self.Owner = spec.Owner
		self.Radius = spec.Radius
		
		self.RateOfFire = 1	-- ticks
		
        SetCollisionShape( self, 'Sphere', 0, 0, 0, spec.Radius)
        
        SetDrawScale( self, spec.Radius)
		
        self:AttachTo(spec.Owner, spec.AttachBone)
		
		LOUDSTATE(self, self.WaitingState)

    end,

    OnDestroy = function(self)
        Entity.OnDestroy(self)
        LOUDSTATE(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    WaitingState = State{

	    -- Return true to process this collision, false to ignore it.
		OnCollisionCheck = function(self, other)

            if other != self.EnemyProj and IsEnemy( self.Army, GetArmy(other) ) then

                if LOUDENTITY( categories.MISSILE * categories.ANTIAIR, other) then
					
					other:SetVelocity(1)
					
					-- ok we can touch the projectile
					self.Enemy = GetLauncher(other)
					self.EnemyProj = other
				
					if self.Enemy then

						other:SetNewTarget(self.Enemy)
						other:TrackTarget(true)
						other:SetTurnRate(540)

						LOUDSTATE(self, self.RedirectingState)
					end
				end
            end
			
            return false
        end,
    },

    RedirectingState = State{

        Main = function(self)

            if not self or BeenDestroyed(self) 
				or not self.EnemyProj or BeenDestroyed(self.EnemyProj) 
				or not self.Owner or self.Owner.Dead then
				
                return
            end

            local beams = {}
            local count = 0

            
            for _, v in self.RedirectBeams do
            
                count = count + 1
                beams[count] = AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, self.Army, v)
                
            end
            
            if self.Enemy then
                -- Set collision to friends active so that when the missile reaches its source it can deal damage. 
			    self.EnemyProj.DamageData.CollideFriendly = true         
			    self.EnemyProj.DamageData.DamageFriendly = true 
			    self.EnemyProj.DamageData.DamageSelf = true 
			end
			
            if self.Enemy and not BeenDestroyed(self.Enemy) then

                WaitTicks( self.RateOfFire )
				
                if not BeenDestroyed(self.EnemyProj) then
                    self.EnemyProj:TrackTarget(false)
                end
				
            else
				
                local vectordam = {}
                vectordam.x = 0
                vectordam.y = 1
                vectordam.z = 0
				
				--LOG("*AI DEBUG Missile Destroy")
				
                self.EnemyProj:Destroy()	--DoTakeDamage(self.Owner, 30, vectordam,'Fire')

                WaitTicks( self.RateOfFire )

            end
			
            for _, v in beams do
                v:Destroy()
            end
			
            LOUDSTATE(self, self.WaitingState)
        end,

        OnCollisionCheck = function(self, other)

            return false
        end,
    },
	
}

MissileRedirect = Class(Entity) {

    RedirectBeams = {'/effects/emitters/particle_cannon_beam_02_emit.bp'},
    EndPointEffects = {'/effects/emitters/particle_cannon_end_01_emit.bp',},

    OnCreate = function(self, spec)
	
        Entity.OnCreate(self, spec)
		
        self.Army = spec.Owner.Sync.army
        self.Owner = spec.Owner
        self.Radius = spec.Radius
        self.RedirectRateOfFire = spec.RedirectRateOfFire or 1
        
        SetCollisionShape( self,'Sphere', 0, 0, 0, self.Radius)
        
        SetDrawScale( self, self.Radius)
        
        self.AttachBone = spec.AttachBone
        self:AttachTo(spec.Owner, spec.AttachBone)
		
        LOUDSTATE(self, self.WaitingState)
		
        -- rest of the code is for loyalist tactical missile deflection fix   [161]
        local bp = self:GetBlueprint()
        local ProjectileCategories = bp.ProjectileCategories or { 'MISSILE -STRATEGIC' }
        
        local ParsedProjectileCategories = {}
        local count = 0

        for k, category in ProjectileCategories do
		
            if type(category) == 'string' then
			
                count = count + 1
                ParsedProjectileCategories[count] = LOUDPARSE(category)
				
            else
			
                count = count + 1
                ParsedProjectileCategories[count] = category
				
            end
			
        end

        self.ProjectileCategories = ParsedProjectileCategories
		
    end,
	
    GetBlueprint = function(self)
        return __blueprints[self.Owner.BlueprintID].Defense.AntiMissile
    end,
	
    OnDestroy = function(self)
        Entity.OnDestroy(self)
        LOUDSTATE(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    WaitingState = State{
	
	    -- Return true to process this collision, false to ignore it.
		OnCollisionCheck = function(self, other)

            if other != self.EnemyProj and IsEnemy( self.Army, GetArmy(other) ) then

                -- check if we can touch the projectile  [161]
                local match = false
				
                for k, cat in self.ProjectileCategories do
				
                    if LOUDENTITY(cat, other) then
                        match = true
                        break
                    end
					
                end
				
                if not match then
                    return false
                end

                -- ok we can touch the projectile
                self.Enemy = GetLauncher(other)
                self.EnemyProj = other
				
                if self.Enemy then
				
                    other:SetNewTarget(self.Enemy)
                    other:TrackTarget(true)
                    other:SetTurnRate(720)
					
                end
				
                LOUDSTATE( self, self.RedirectingState)
            end
			
            return false
        end,
    },

    RedirectingState = State{

        Main = function(self)
		
            if not self or BeenDestroyed(self) 
            or not self.EnemyProj or BeenDestroyed(self.EnemyProj) 
            or not self.Owner or self.Owner.Dead then
                return
            end
            
            local beams = {}
            local count = 0

            for _, v in self.RedirectBeams do
                count = count + 1
                beams[count] = AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, self.Army, v)
            end
            
            if self.Enemy then
                -- Set collision to friends active so that when the missile reaches its source it can deal damage. 
			    self.EnemyProj.DamageData.CollideFriendly = true         
			    self.EnemyProj.DamageData.DamageFriendly = true 
			    self.EnemyProj.DamageData.DamageSelf = true 
			end
			
            if self.Enemy and not BeenDestroyed(self.Enemy) then
			
                WaitTicks( (1/self.RedirectRateOfFire) * 10)
				
                if not BeenDestroyed(self.EnemyProj) then
                    self.EnemyProj:TrackTarget(false)
                end
				
            else
			
                WaitTicks( (1/self.RedirectRateOfFire) * 10)
				
                local vectordam = {}
                vectordam.x = 0
                vectordam.y = 1
                vectordam.z = 0
				
                self.EnemyProj:DoTakeDamage(self.Owner, 30, vectordam,'Fire')
            end
			
            for _, v in beams do
                v:Destroy()
            end
			
            LOUDSTATE(self, self.WaitingState)
        end,

        OnCollisionCheck = function(self, other)
            return false
        end,
    },

}

SeraLambdaFieldRedirector = Class(Entity) {

    RedirectBeams = {'/effects/emitters/particle_cannon_beam_02_emit.bp'},
    LambdaEffects = {},

    OnCreate = function(self, spec)
        Entity.OnCreate(self, spec)
        
        self.Army = spec.Owner.Sync.army
        self.Owner = spec.Owner

        self.Radius = spec.Radius
        self.RedirectRateOfFire = spec.RedirectRateOfFire or 1
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, self.Radius)
        SetDrawScale( self, self.Radius )
        
        self.AttachBone = spec.AttachBone
        self:AttachTo(spec.Owner, spec.AttachBone)
        
        LOUDSTATE( self, self.WaitingState)
        
		--self.LambdaEffectsBag = {}
    end,

    OnDestroy = function(self)
        Entity.OnDestroy(self)
        LOUDSTATE(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    -- Return true to process this collision, false to ignore it.
    WaitingState = State{
    
        OnCollisionCheck = function(self, other)
            
            if other.lastRedirector and other.lastRedirector == self.Army then
                return false
            end
            
            if LOUDENTITY(categories.PROJECTILE, other)
            and not LOUDENTITY(categories.STRATEGIC, other) 
            and other != self.EnemyProj and IsEnemy( self.Army, GetArmy(other) ) then
            
                -- mark projectile as having been redirected by us
                other.lastRedirector = self.Army

                self.Enemy = GetLauncher(other)

                self.EnemyProj = other
				self.EXFiring = false
                
                if self.Enemy then --and (not other.lastRedirector or other.lastRedirector != selfarmy) then

                    --LOG("*AI DEBUG Redirection to launcher")
                    
                    other:SetNewTarget(self.Enemy)
                    other:TrackTarget(true)
                    other:SetTurnRate(720)
                    
					local targetspeed = other:GetCurrentSpeed()
                    
					other:SetVelocity( targetspeed * 2)

					self.EXFiring = true
                end
                
				if self.EXFiring then
					LOUDSTATE(self, self.RedirectingState)
				end
                
            end
            
            return false
        end,
    },

    RedirectingState = State{

        Main = function(self)
		
            if not self or self:BeenDestroyed()
            or not self.EnemyProj or BeenDestroyed( self.EnemyProj )
            or not self.Owner or self.Owner.Dead then
                return
            end
            
            local beams = {}
            local count = 0
            
            for _, v in self.RedirectBeams do
                count = count + 1
                beams[count] = AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, self.Army, v)
            end
            
            if self.Enemy then
                -- Set collision to friends active so that when the missile reaches its source it can deal damage. 
			    self.EnemyProj.DamageData.CollideFriendly = true         
			    self.EnemyProj.DamageData.DamageFriendly = true 
			    self.EnemyProj.DamageData.DamageSelf = true 
			end
            
            if self.Enemy and not BeenDestroyed(self.Enemy) then
--[[			
			    for _, v in self.LambdaEffects do
                    LOUDINSERT( self.LambdaEffectsBag, LOUDEMITONENTITY( self.EnemyProj, self.Army, v ):ScaleEmitter(0.5) )
				end
--]]                
				WaitTicks(self.RedirectRateOfFire)
                
                if not BeenDestroyed( self.EnemyProj ) then
                    self.EnemyProj:TrackTarget(false)
                end
                
            else	-- just destroy the projectile
				self.EnemyProj:Destroy()
            end
			
            for _, v in beams do
                v:Destroy()
            end
			
            LOUDSTATE(self, self.WaitingState)
            
        end,

        OnCollisionCheck = function(self, other)
            return false
        end,
    },

}

SeraLambdaFieldDestroyer = Class(Entity) {

    RedirectBeams = {'/effects/emitters/particle_cannon_beam_02_emit.bp'},
    LambdaEffects = {},
    
    OnCreate = function(self, spec)
        Entity.OnCreate(self, spec)
        
        self.Army = GetArmy(self)
        self.Owner = spec.Owner

        self.Radius = spec.Radius
        self.RedirectRateOfFire = spec.RedirectRateOfFire or 1

        SetCollisionShape( self, 'Sphere', 0, 0, 0, self.Radius)
        SetDrawScale( self, self.Radius )
        
        self.AttachBone = spec.AttachBone
        self:AttachTo(spec.Owner, spec.AttachBone)
		
        LOUDSTATE(self, self.WaitingState)
        
		--self.LambdaEffectsBag = {}
    end,

    OnDestroy = function(self)
        Entity.OnDestroy(self)
        LOUDSTATE(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    -- Return true to process this collision, false to ignore it.
    WaitingState = State{
	
        OnCollisionCheck = function(self, other)

            if other.lastRedirector and other.lastRedirector == self.Army then
                return false
            end

            if LOUDENTITY(categories.PROJECTILE, other)
            and not LOUDENTITY(categories.STRATEGIC, other)
            and not LOUDENTITY(categories.ANTINAVY, other) 
            and other != self.EnemyProj and IsEnemy( self.Army, GetArmy(other) ) then
                
                self.Enemy = GetLauncher(other)
                self.EnemyProj = other
				self.EXFiring = false
                
                if self.Enemy then
                
                    other.lastRedirector = self.Army

					other:SetVelocity( 2 )
                    
                    other:SetNewTarget(self.Enemy)
                    other:TrackTarget(true)
                    other:SetTurnRate(720)

                    -- go and destroy projectile
					LOUDSTATE(self, self.RedirectingState)
				end
                
            end
            
            return false
        end,
    },

    RedirectingState = State{

        Main = function(self)
		
            if not self or self:BeenDestroyed()
            or not self.EnemyProj or BeenDestroyed( self.EnemyProj )
            or not self.Owner or self.Owner.Dead then
                return
            end

            local beams = {}
            local count = 0

            for _, v in self.RedirectBeams do
                count = count + 1
                beams[count] = AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, self.Army, v)
            end
--[[
		    for _, v in self.LambdaEffects do
				LOUDINSERT( self.LambdaEffectsBag, CreateEmitterAtEntity( self.EnemyProj, self.Army, v ):ScaleEmitter(0.8) )
			end
--]]            
            WaitTicks(self.RedirectRateOfFire)

            if not BeenDestroyed( self.EnemyProj) then
                self.EnemyProj:Destroy()
            end
			
            for _, v in beams do
                v:Destroy()
            end

            LOUDSTATE(self, self.WaitingState)
        end,

        OnCollisionCheck = function(self, other)
            return false
        end,
    },

}
