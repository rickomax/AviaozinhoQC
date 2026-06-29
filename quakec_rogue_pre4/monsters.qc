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

/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + nexttime;
//		self.think = nextthink
//		<code>
// };


//============================================================================
// TRIGGER SPAWNING

void(entity e) hide_spawned_monster_entity = {
	//store the important info in unused fields
	e.mdl = e.model;
	e.cmins = e.mins;
	e.cmaxs = e.maxs;
	e.walkframe = e.solid;
	e.fly_sound = e.movetype;

	//hide the model and make it non-solid
	e.model = "";
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
}

void(entity e) show_spawned_monster_entity = {
	e.solid = e.walkframe;
	e.movetype = e.fly_sound;
	setmodel(e, e.mdl);
	setsize (e, e.cmins, e.cmaxs);
}

void() spawn_monster_use = {
	if (self.delay || self.rand) {
		self.think = spawn_monster;
		self.nextthink = time + self.delay + self.rand*random();
	}
	else
		spawn_monster();
};

void() spawn_monster = {

	show_spawned_monster_entity(self);

	//if (self.trigger_field) show_spawned_monster_entity(self.trigger_field); // Double-entity monster

	//telefrag any existing entities
	spawn_tdeath (self.origin, self); 

	//sound and particle effects	
	if (!(self.spawnflags & MONSTER_SPAWNSILENT))
		spawn_tfog (self.origin);	

	self.think1();
}

void(entity e, void() go_function) init_spawned_monster = {

	hide_spawned_monster_entity(e);

	// Double-entity Malice monsters must have both parts hidden.
	// Secondary entity is always stored in the trigger_field field so we check that
	//if (e.trigger_field) hide_spawned_monster_entity(e.trigger_field);

	//set up the teleport functions

	e.use = spawn_monster_use;
	e.think1 = go_function;
}

/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/
void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;
	if (activator.items & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;
	
// delay reaction so if the monster is teleported, its sound is still
// heard
	self.enemy = activator;
	self.nextthink = time + 0.1;
	self.think = FoundTarget;
};

/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/
void() monster_death_use =
{
	local entity 	ent, otemp, stemp;

// fall to ground
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;
	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;

	// horde merge: monsters dying need to update the wave manager
	if (cvar("horde") && self.classname != "monster_zombie")
	{
		remote_wavecheck();
	}

	if (!self.target)
		return;

	activator = self.enemy;
	SUB_UseTargets ();
};


//============================================================================

void() walkmonster_start_go =
{
local string	stemp;
local entity	etemp;

	self.origin_z = self.origin_z + 1;	// raise off floor a bit
	droptofloor();
	
	if (!walkmove(0,0))
	{
		dprint ("walkmonster in wall!\n");
		dprint (self.classname);
		dprint (" at ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}
	
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	self.team = TEAM_MONSTERS;
	
	self.flags = self.flags | FL_MONSTER;
	
	if (self.target != "")
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
			self.pausetime = 99999999;
			self.th_stand ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

	if (self.spawnflags & (MONSTER_SPAWNANGRY + MONSTER_SPAWNTRIGGERED))
		monster_use();
	else
		self.nextthink = self.nextthink + random()*0.5;
// spread think times so they don't all happen at same time
	
};


void() walkmonster_start =
{
// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
	if (self.spawnflags & MONSTER_SPAWNTRIGGERED) {
		init_spawned_monster(self, walkmonster_start_go);
	}
	else {
		self.nextthink = self.nextthink + random()*0.5;
		self.think = walkmonster_start_go;
	}
	
	total_monsters = total_monsters + 1;
};



void() flymonster_start_go =
{
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 25';
	self.use = monster_use;
	self.team = TEAM_MONSTERS;

	self.flags = self.flags | FL_FLY;
	self.flags = self.flags | FL_MONSTER;

	if (!walkmove(0,0))
	{
		dprint ("flymonster in wall!\n");
		dprint (self.classname);
		dprint (" at ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}

	if (self.target != "")
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
			self.pausetime = 99999999;
			self.th_stand ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

	if (self.spawnflags & (MONSTER_SPAWNANGRY + MONSTER_SPAWNTRIGGERED))
		monster_use();
};

void() flymonster_start =
{
// spread think times so they don't all happen at same time
	if (self.spawnflags & MONSTER_SPAWNTRIGGERED) {
		init_spawned_monster(self, flymonster_start_go);
	}
	else {
		self.nextthink = self.nextthink + random()*0.5;
		self.think = flymonster_start_go;
	}
	total_monsters = total_monsters + 1;
};


void() swimmonster_start_go =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 10';
	self.use = monster_use;
	self.team = TEAM_MONSTERS;
	
	self.flags = self.flags | FL_SWIM;
	self.flags = self.flags | FL_MONSTER;

	if (self.target != "")
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		self.th_walk ();
	}
	else
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}
	
	
	if (self.spawnflags & (MONSTER_SPAWNANGRY + MONSTER_SPAWNTRIGGERED))
		monster_use();
	else
		self.nextthink = self.nextthink + random()*0.5;
// spread think times so they don't all happen at same time

};

void() swimmonster_start =
{
// spread think times so they don't all happen at same time
	if (self.spawnflags & MONSTER_SPAWNTRIGGERED) {
		init_spawned_monster(self, swimmonster_start_go);
	}
	else {
		self.nextthink = self.nextthink + random()*0.5;
		self.think = swimmonster_start_go;
	}

	total_monsters = total_monsters + 1;
};


