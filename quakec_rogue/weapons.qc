/*  Copyright (C) 1996-2022 id Software LLC

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

/*
*/

float lavaGunFired;

void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;
void W_FirePlasma();


// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun

//ZOID--
	// grapple
	precache_sound("weapons/chain1.wav");
//	precache_sound("weapons/chain2.wav");
//	precache_sound("weapons/chain3.wav");
//	precache_sound("weapons/bounce2.wav");
//	precache_sound("blob/land1.wav");
	precache_sound("pendulum/hit.wav");
//--ZOID

	precache_sound ("lavagun/snail.wav");		// lava nail gun cooldown
};

float() crandom =
{
	return 2*(random() - 0.5);
};

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	local	vector	source;
	local	vector	org;

	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, self);
	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		SpawnBlood (org, '0 0 0', 20);
		T_Damage (trace_ent, self, self, 20);
	}
	else
	{	// hit wall
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};


//============================================================================


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile, mpuff;
	local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float damage) SpawnBlood =
{
	particle (org, vel*0.1, 73, damage*2);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, damage);
};


/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnBlood (org, vel*0.2, damage);
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	self.punchangle_x = -2;
	
	self.currentammo = self.ammo_shells1 = self.ammo_shells1 - 1;
	UpdateAmmoCounts(self);
	dir = aim (self, 100000);
	FireBullets (6, dir, '0.04 0.04 0');
};


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	self.punchangle_x = -4;
	
	self.currentammo = self.ammo_shells1 = self.ammo_shells1 - 2;
	UpdateAmmoCounts(self);
	dir = aim (self, 100000);
	FireBullets (14, dir, '0.14 0.08 0');
};


/*
==============================================================================

ROCKETS

==============================================================================
*/

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() T_MissileTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 100 + random()*20;
	
	if (other.health)
	{
		if (other.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};



/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
	local	entity missile, mpuff;
	
	self.currentammo = self.ammo_rockets1 = self.ammo_rockets1 - 1;
	UpdateAmmoCounts(self);
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	
// set missile speed	

	makevectors (self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = T_MissileTouch;
	
// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward*8 + '0 0 16');
};

/*

===============================================================================

AVIAO


===============================================================================
================
W_AVIAO
================
*/
void W_FirePlasma();
/*

===============================================================================

LIGHTNING

===============================================================================
*/

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
};


void() W_FireLightning =
{
	local	vector		org;
	local	float		cells;

	if (self.ammo_cells1 < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells1;
		self.ammo_cells1 = 0;
		W_SetCurrentAmmo ();
		T_RadiusDamage (self, self, 35*cells, world);
		return;
	}

	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
	self.punchangle_x = -2;

	self.currentammo = self.ammo_cells1 = self.ammo_cells1 - 1;
	UpdateAmmoCounts(self);

	org = self.origin + '0 0 16';
	
	makevectors (self.v_angle);
	traceline (org, org + v_forward*600, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

	LightningDamage (self.origin + '0 0 16', trace_endpos + v_forward*4, self, 30);
};


//=============================================================================


void() GrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 120, world);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	local	entity missile, mpuff;
	
	self.currentammo = self.ammo_rockets1 = self.ammo_rockets1 - 1;
	UpdateAmmoCounts(self);
	
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
		
// set missile speed	

	makevectors (self.v_angle);

	if (self.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = GrenadeTouch;
	
// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin);
};


//=============================================================================

void() spike_touch;
void() superspike_touch;
void() lavaspike_touch;
void() superlavaspike_touch;

/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
	local vector	dir;
	local entity	old;
	
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;

	self.currentammo = self.ammo_nails1 = self.ammo_nails1 - 2;
	UpdateAmmoCounts(self);

	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);			
	self.punchangle_x = -2;
};

void(float ox) W_FireSpikes =
{
	local vector	dir;
	local entity	old;
	
	makevectors (self.v_angle);
	
	if (self.ammo_nails1 >= 2 && self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails1 < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails1 = self.ammo_nails1 - 1;
	UpdateAmmoCounts(self);

	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);

	self.punchangle_x = -2;
};

.float hit_z;
void() spike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		T_Damage (other, self, self.owner, 9);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() superspike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	player_run ();		// get out of any weapon firing states

	self.items = self.items - 
		( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
	self.items2 = self.items2 - 
		(self.items2 & (IT2_LAVA_NAILS|IT2_PLASMA_AMMO|IT2_MULTI_ROCKETS));
	
	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
		self.weaponframe = 0;
	}
//ZOID--
	else if (self.weapon == IT_GRAPPLE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_grpple.mdl";
		self.weaponframe = 0;
	}
//--ZOID
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells1;
		self.weaponmodel = "progs/v_shot.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells1;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_LAVA_NAILGUN)
	{
		self.currentammo = self.ammo_lava_nails;
		self.weaponmodel = "progs/v_lava.mdl";
		self.weaponframe = 0;
		self.items2 = self.items2 | IT2_LAVA_NAILS;
	}
	else if (self.weapon == IT_LAVA_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_lava_nails;
		self.weaponmodel = "progs/v_lava2.mdl";
		self.weaponframe = 0;
		self.items2 = self.items2 | IT2_LAVA_NAILS;
	}
	else if (self.weapon == IT_MULTI_GRENADE)
	{
		self.currentammo = self.ammo_multi_rockets;
		self.weaponmodel = "progs/v_multi.mdl";
		self.weaponframe = 0;
		self.items2 = self.items2 | IT2_MULTI_ROCKETS;
	}
	else if (self.weapon == IT_MULTI_ROCKET)
	{
			
		self.currentammo = self.ammo_multi_rockets;
		self.weaponmodel = "progs/v_multi2.mdl";
		self.weaponframe = 0;
		self.items2 = self.items2 | IT2_MULTI_ROCKETS;
	}
	else if (self.weapon == IT_AVIAO)
	{
		self.currentammo = self.ammo_plasma;
		self.weaponmodel = "progs/v_plasma.mdl";
		self.weaponframe = 0;
		self.items2 = self.items2 | IT2_PLASMA_AMMO;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails1;
		self.weaponmodel = "progs/v_nail.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails1;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets1;
		self.weaponmodel = "progs/v_rock.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets1;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells1;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
		
	UpdateAmmoCounts(self);
};

float() W_BestWeapon =
{
	local	float	it;

	it = self.items;

// pgm - fix for sandy. will not change to plasma gun
	
//	if(self.waterlevel <= 1 && self.ammo_plasma >= 1 && (it & IT_AVIAO))
//		return IT_AVIAO;
//	else 
	if(self.waterlevel<=1 && self.ammo_cells1>=1 && (it & IT_LIGHTNING))
		return IT_LIGHTNING;
	else if(self.ammo_lava_nails >= 2 && (it & IT_LAVA_SUPER_NAILGUN) )
		return IT_LAVA_SUPER_NAILGUN;
	else if(self.ammo_nails1 >= 2 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	else if(self.ammo_lava_nails >= 1 && (it & IT_LAVA_NAILGUN) )
		return IT_LAVA_NAILGUN;
	else if(self.ammo_nails1 >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;
	else if(self.ammo_shells1 >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	else if(self.ammo_shells1 >= 1 && (it & IT_SHOTGUN) )
		return IT_SHOTGUN;
		
	return IT_AXE;
};

float(entity playerEnt, float old, float new) W_WantsToChangeWeapon =
{
	float playerFlags = CheckPlayerEXFlags(playerEnt);
	if((playerFlags & PEF_CHANGENEVER) != 0)
	{
		return 0;
	}
	
	if(((playerFlags & PEF_CHANGEONLYNEW) != 0) && old == new)
	{
		return 0;
	}

	return 1;
};

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;

//ZOID--
	if (self.weapon == IT_AXE || self.weapon == IT_GRAPPLE)
		return TRUE;
//--ZOID
	
	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();
	
// drop the weapon down
	return FALSE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;
void W_FirePlasma();
void()	player_light1;
void()	player_rocket1;
void()	player_lava_nail1;
//ZOID--
void()  player_grapple1;
void()  player_grapple3;
//--ZOID

void() W_FireMultiGrenade;
void() W_FireMultiRocket;

void() W_Attack =
{
	local	float	r;

	if (!W_CheckNoAmmo ())
		return;

	makevectors	(self.v_angle);		// calculate forward angle for velocity
	self.show_hostile = time + 1;	// wake monsters up

// ZOID--
	RuneApplyBlackNoise(self); // make rune noise
//--ZOID

	if (self.weapon == IT_AXE)
	{
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		r = random();
		if (r < 0.25)
			player_axe1 ();
		else if (r<0.5)
			player_axeb1 ();
		else if (r<0.75)
			player_axec1 ();
		else
			player_axed1 ();
		self.attack_finished = time + RuneApplyHell(0.5, self);
	}
//ZOID--
	else if (self.weapon == IT_GRAPPLE)
	{
		if (!self.hook_out)
			player_grapple1();
		else
			player_grapple3();
		self.attack_finished = time + 0.1;
	}
//--ZOID
	else if (self.weapon == IT_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();
		self.attack_finished = time + RuneApplyHell(0.5, self);
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1 ();
		W_FireSuperShotgun ();
		self.attack_finished = time + RuneApplyHell(0.7, self);
	}
	else if (self.weapon == IT_LAVA_NAILGUN)
	{
		lavaGunFired = 1;
		player_lava_nail1 ();
	}
	else if (self.weapon == IT_LAVA_SUPER_NAILGUN)
	{
		lavaGunFired = 1;
		player_lava_nail1 ();
	}
	else if (self.weapon == IT_MULTI_GRENADE)
	{
		player_rocket1();
		W_FireMultiGrenade();
		self.attack_finished = time + RuneApplyHell(0.6, self);
	}
	else if (self.weapon == IT_MULTI_ROCKET)
	{
		player_rocket1();
		W_FireMultiRocket();
		self.attack_finished = time + RuneApplyHell(0.52, self);
	}
else if (self.weapon == IT_AVIAO)
        {
                player_rocket1();
                W_FirePlasma();
                self.attack_finished = time + RuneApplyHell(1.0, self);
        }
	else if (self.weapon == IT_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
		self.attack_finished = time + RuneApplyHell(0.6, self);
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
		self.attack_finished = time + RuneApplyHell(0.8, self);
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		player_light1();
		self.attack_finished = time + 0.1;
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl; 
		
	EnableComboWeapons ( self );
	UpdateAmmoCounts ( self );

	it = self.items;
	am = 0;
	
	if (self.impulse == 1)
	{
//ZOID--
		if (self.weapon == IT_AXE && deathmatch && teamplay >= TEAM_CTF)
			fl = IT_GRAPPLE;
		else
			fl = IT_AXE;
	}
	else if (self.impulse == 22)
	{
		if(deathmatch && teamplay >= TEAM_CTF)		//pgm optimization
			fl = IT_GRAPPLE;
	}
//--ZOID
	else if (self.impulse == 2)
	{
		fl = IT_SHOTGUN;
		if (self.ammo_shells1 < 1)
			am = 1;
	}
	else if (self.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;
		if (self.ammo_shells1 < 2)
			am = 1;
	}	
	else if (self.impulse == 4)
	{
		if ((self.items & IT_LAVA_NAILGUN) && 
				(self.weapon == IT_NAILGUN || self.ammo_nails1 < 1))
		{
			fl = IT_LAVA_NAILGUN;
			if (self.ammo_lava_nails < 1)
				am = 1;
		}
		else
		{
			fl = IT_NAILGUN;
			if (self.ammo_nails1 < 1)
				am = 1;
		}
	}
	else if (self.impulse == 5)
	{
		if ((self.items & IT_LAVA_SUPER_NAILGUN) && 
				(self.weapon == IT_SUPER_NAILGUN || self.ammo_nails1 < 2))
		{
			fl = IT_LAVA_SUPER_NAILGUN;
			if (self.ammo_lava_nails < 2)
				am = 1;
		}
		else
		{
			fl = IT_SUPER_NAILGUN;
			if (self.ammo_nails1 < 2)
				am = 1;
		}
	}
	else if (self.impulse == 6)
	{
		if ((self.items & IT_MULTI_GRENADE) && 
				(self.weapon == IT_GRENADE_LAUNCHER || self.ammo_rockets1 < 1))
		{
			fl = IT_MULTI_GRENADE;
			if (self.ammo_multi_rockets < 1)
				am = 1;
		}
		else
		{
			fl = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets1 < 1)
				am = 1;
		}
	}
	else if (self.impulse == 7)
	{
		if ((self.items & IT_MULTI_ROCKET) && 
			(self.weapon == IT_ROCKET_LAUNCHER || self.ammo_rockets1 < 1))
		{
			fl = IT_MULTI_ROCKET;
			if (self.ammo_multi_rockets < 1)
				am = 1;
		}
		else
		{
			fl = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets1 < 1)
				am = 1;
		}
	}
	else if (self.impulse == 8)
	{
		if ((self.items & IT_AVIAO) && 
				(self.weapon == IT_LIGHTNING || self.ammo_cells1 < 1))
		{
			fl = IT_AVIAO;
			if (self.ammo_plasma < 1)
				am = 1;
		}
		else
		{
			fl = IT_LIGHTNING;
			if (self.ammo_cells1 < 1)
				am = 1;
		}
	}
	else if (self.impulse == 60)
	{
		fl = IT_LAVA_NAILGUN;
		if (self.ammo_lava_nails < 1)
			am = 1;
	}
	else if (self.impulse == 61)
	{
		fl = IT_LAVA_SUPER_NAILGUN;
		if (self.ammo_lava_nails < 1)
			am = 1;
	}
	else if (self.impulse == 62)
	{
		fl = IT_MULTI_GRENADE;
		if (self.ammo_multi_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 63)
	{
		fl = IT_MULTI_ROCKET;
		if (self.ammo_multi_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 64)
	{
		fl = IT_AVIAO;
		if (self.ammo_plasma < 1)
			am = 1;
	}
	else if (self.impulse == 65)
	{
		fl = IT_NAILGUN;

		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.impulse == 66)
	{
		fl = IT_SUPER_NAILGUN;

		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (self.impulse == 67)
	{
		fl = IT_GRENADE_LAUNCHER;

		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 68)
	{
		fl = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}

	self.impulse = 0;
	
	if (!(self.items & fl))
	{	// don't have the weapon or the ammo
		sprint (self, "$qc_no_weapon");
		return;
	}

	if (am)
	{	// don't have the ammo
		sprint (self, "$qc_not_enough_ammo");
		return;
	}
	

	if (self.weapon != fl)
	{
		if (self.weapon == IT_LAVA_NAILGUN || 
				self.weapon == IT_LAVA_SUPER_NAILGUN)
		{
			if (fl == IT_NAILGUN || fl == IT_SUPER_NAILGUN)
				sprint (self, "$qc_normal_nails");
		}
		else if (self.weapon == IT_MULTI_GRENADE)
		{
			if (fl == IT_GRENADE_LAUNCHER)
				sprint (self, "$qc_normal_nails");
		}
		else if (self.weapon == IT_MULTI_ROCKET)
		{
			if (fl == IT_ROCKET_LAUNCHER)
				sprint (self, "$qc_normal_rockets");
		}
		else if (self.weapon == IT_AVIAO)
		{
			if (fl == IT_LIGHTNING)
				sprint (self, "$qc_lightning_gun");
		}
		else if (fl == IT_LAVA_NAILGUN || fl == IT_LAVA_SUPER_NAILGUN)
		{
			sprint (self, "$qc_lava_nails");
		}
		else if(fl == IT_MULTI_GRENADE)
		{
			sprint (self, "$qc_multi_gl");
		}
		else if(fl == IT_MULTI_ROCKET)
		{
			sprint (self, "$qc_multi_rl");
		}
		else if(fl == IT_AVIAO)
		{
			sprint (self, "$qc_plasma_gun");
		}
	}
	
//
// set weapon, set ammo
//	
	self.weapon = fl;
	W_SetCurrentAmmo ();
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	if ( ( deathmatch || coop ) && cheats_allowed == 0 ) { // mal: allow impulse 9 IF cheats allowed
		return;
	}

	self.ammo_rockets1 = 100;
	self.ammo_nails1 = 200;
	self.ammo_shells1 = 100;
	self.ammo_lava_nails = 200;
	self.ammo_multi_rockets = 100;
	self.ammo_plasma = 100;
	self.ammo_cells1 = 200;	
	self.items = self.items | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_KEY1 | IT_KEY2;

	self.ammo_cells1 = 200;
	self.items = self.items | IT_LIGHTNING;

	self.weapon = IT_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am;
	
	EnableComboWeapons ( self );
	UpdateAmmoCounts ( self );

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == IT_AVIAO)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
//ZOID--
			if (deathmatch && teamplay >= TEAM_CTF)
				self.weapon = IT_GRAPPLE;
			else
			{
				self.weapon = IT_SHOTGUN;
				if (self.ammo_shells1 < 1)
					am = 1;
			}
//--ZOID
		}
		else if (self.weapon == IT_GRAPPLE)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells1 < 1)
				am = 1;
		}
//--ZOID
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells1 < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails1 < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_LAVA_NAILGUN;
			if (self.ammo_lava_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_LAVA_NAILGUN)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails1 < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_LAVA_SUPER_NAILGUN;
			if (self.ammo_lava_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_LAVA_SUPER_NAILGUN)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets1 < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_MULTI_GRENADE;
			if (self.ammo_multi_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_MULTI_GRENADE)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets1 < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_MULTI_ROCKET;
			if (self.ammo_multi_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_MULTI_ROCKET)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells1 < 1)
				am = 1;
		}
		else if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_AVIAO;
			if (self.ammo_plasma < 1)
				am = 1;
		}

		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local	float	it, am;
	
	EnableComboWeapons ( self );
	UpdateAmmoCounts ( self );

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == IT_AVIAO)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells1 < 1)
				am = 1;
		}
		else if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_MULTI_ROCKET;
			if (self.ammo_multi_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_MULTI_ROCKET)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets1 < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_MULTI_GRENADE;
			if (self.ammo_multi_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_MULTI_GRENADE)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets1 < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_LAVA_SUPER_NAILGUN;
			if (self.ammo_lava_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_LAVA_SUPER_NAILGUN)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails1 < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_LAVA_NAILGUN;
			if (self.ammo_lava_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_LAVA_NAILGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails1 < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells1 < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells1 < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
//PGM
			if (deathmatch && teamplay >= TEAM_CTF)
				self.weapon = IT_GRAPPLE;
			else
				self.weapon = IT_AXE;
//PGM
		}
//ZOID--
		else if (self.weapon == IT_GRAPPLE) 
		{
			self.weapon = IT_AXE;
		}
//--ZOID
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_AVIAO;
			if (self.ammo_plasma < 1)
				am = 1;
		}
	
		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};

void() QuadCheat =
{
	if (deathmatch || coop)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("$qc_quad_cheat");
};


/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	local entity takeThisOut;
	
	if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon ();
	else if (self.impulse >= 60 && self.impulse <= 68)
		W_ChangeWeapon ();
	else if (self.impulse == 9)
		CheatCommand ();
	else if (self.impulse == 10)
		CycleWeaponCommand ();
	else if (self.impulse == 11)
		ServerflagsCommand ();
	else if (self.impulse == 12)
		CycleWeaponReverseCommand ();
//ZOID--
//teamplay stuff
	else if (self.impulse == 20)
		TossBackpack();
	else if (self.impulse == 21)
		TossWeapon();
	else if (self.impulse == 22)
	{
		if (deathmatch && teamplay >= TEAM_CTF)
			W_ChangeWeapon();
	}
	else if (self.impulse == 23)
		TeamFlagStatusReport();
//--ZOID

	else if (self.impulse == 255)
		QuadCheat ();
		
	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (time < self.attack_finished)
		return;

	if (lavaGunFired)
	{
		if (self.weapon == IT_LAVA_NAILGUN || 
			self.weapon == IT_LAVA_SUPER_NAILGUN)
		{
			sound (self, CHAN_WEAPON, "lavagun/snail.wav", 1, ATTN_NORM);
		}
		lavaGunFired = 0;
	}
	
	if (self.impulse)
		ImpulseCommands ();
	
// check for attack
	if (self.button0)
	{
		SuperDamageSound ();
		W_Attack ();
	}
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};


