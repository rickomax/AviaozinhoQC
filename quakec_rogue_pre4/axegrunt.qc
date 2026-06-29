/* Copyright (C) 1996-2022 id Software LLC
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
    See file, 'COPYING', for details.
*/
/*
==============================================================================
AXE GRUNT
==============================================================================
*/
$cd /raid/quake/id1/models/axegrunt
$origin 0 0 24
$base base
$skin badass3
$skin statue
$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame runb1 runb2 runb3 runb4 runb5 runb6 runb7 runb8
//frame runc1 runc2 runc3 runc4 runc5 runc6
$frame runattack1 runattack2 runattack3 runattack4 runattack5
$frame runattack6 runattack7 runattack8 runattack9 runattack10
$frame runattack11
$frame pain1 pain2 pain3
$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9
$frame painb10 painb11
//frame attack1 attack2 attack3 attack4 attack5 attack6 attack7
//frame attack8 attack9 attack10 attack11
$frame attackb1 attackb1a attackb2 attackb3 attackb4 attackb5
$frame attackb6 attackb7 attackb8 attackb9 attackb10
$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
$frame walk10 walk11 walk12 walk13 walk14
$frame kneel1 kneel2 kneel3 kneel4 kneel5
$frame standing2 standing3 standing4 standing5
$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10
$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9 deathb10 deathb11
void() axegrunt_stand1 =[ $stand1, axegrunt_stand2 ] {ai_stand();};
void() axegrunt_stand2 =[ $stand2, axegrunt_stand3 ] {ai_stand();};
void() axegrunt_stand3 =[ $stand3, axegrunt_stand4 ] {ai_stand();};
void() axegrunt_stand4 =[ $stand4, axegrunt_stand5 ] {ai_stand();};
void() axegrunt_stand5 =[ $stand5, axegrunt_stand6 ] {ai_stand();};
void() axegrunt_stand6 =[ $stand6, axegrunt_stand7 ] {ai_stand();};
void() axegrunt_stand7 =[ $stand7, axegrunt_stand8 ] {ai_stand();};
void() axegrunt_stand8 =[ $stand8, axegrunt_stand9 ] {ai_stand();};
void() axegrunt_stand9 =[ $stand9, axegrunt_stand1 ] {ai_stand();};
void() ax_idle_sound =
{
if (random() < 0.2)
{
if (self.spawnflags & 2) // statue
sound (self, CHAN_VOICE, "statue/idle.wav", 1, ATTN_IDLE);
else
sound (self, CHAN_VOICE, "axegrunt/idle.wav", 1, ATTN_IDLE);
}
};
void() axegrunt_walk1 =[ $walk1, axegrunt_walk2 ]
{ ax_idle_sound(); ai_walk(3);};
void() axegrunt_walk2 =[ $walk2, axegrunt_walk3 ] {ai_walk(2);};
void() axegrunt_walk3 =[ $walk3, axegrunt_walk4 ] {ai_walk(3);};
void() axegrunt_walk4 =[ $walk4, axegrunt_walk5 ] {ai_walk(4);};
void() axegrunt_walk5 =[ $walk5, axegrunt_walk6 ] {ai_walk(3);};
void() axegrunt_walk6 =[ $walk6, axegrunt_walk7 ] {ai_walk(3);};
void() axegrunt_walk7 =[ $walk7, axegrunt_walk8 ] {ai_walk(3);};
void() axegrunt_walk8 =[ $walk8, axegrunt_walk9 ] {ai_walk(4);};
void() axegrunt_walk9 =[ $walk9, axegrunt_walk10 ] {ai_walk(3);};
void() axegrunt_walk10 =[ $walk10, axegrunt_walk11 ] {ai_walk(3);};
void() axegrunt_walk11 =[ $walk11, axegrunt_walk12 ] {ai_walk(2);};
void() axegrunt_walk12 =[ $walk12, axegrunt_walk13 ] {ai_walk(3);};
void() axegrunt_walk13 =[ $walk13, axegrunt_walk14 ] {ai_walk(4);};
void() axegrunt_walk14 =[ $walk14, axegrunt_walk1 ] {ai_walk(3);};
void() axegrunt_run1 =[ $runb1, axegrunt_run2 ]
{ ax_idle_sound(); ai_run(16); };
void() axegrunt_run2 =[ $runb2, axegrunt_run3 ] {ai_run(20);};
void() axegrunt_run3 =[ $runb3, axegrunt_run4 ] {ai_run(13);};
void() axegrunt_run4 =[ $runb4, axegrunt_run5 ] {ai_run(7);};
void() axegrunt_run5 =[ $runb5, axegrunt_run6 ] {ai_run(16);};
void() axegrunt_run6 =[ $runb6, axegrunt_run7 ] {ai_run(20);};
void() axegrunt_run7 =[ $runb7, axegrunt_run8 ] {ai_run(14);};
void() axegrunt_run8 =[ $runb8, axegrunt_run1 ] {ai_run(6);};
void() axegrunt_runatk1 =[ $runattack1, axegrunt_runatk2 ]
{
if (random() > 0.5)
sound (self, CHAN_WEAPON, "axegrunt/sword2.wav", 1, ATTN_NORM);
else
sound (self, CHAN_WEAPON, "axegrunt/sword1.wav", 1, ATTN_NORM);
ai_charge(20);
};
void() axegrunt_runatk2 =[ $runattack2, axegrunt_runatk3 ] {ai_charge_side();};
void() axegrunt_runatk3 =[ $runattack3, axegrunt_runatk4 ] {ai_charge_side();};
void() axegrunt_runatk4 =[ $runattack4, axegrunt_runatk5 ] {ai_charge_side();};
void() axegrunt_runatk5 =[ $runattack5, axegrunt_runatk6 ] {ai_melee_side();};
void() axegrunt_runatk6 =[ $runattack6, axegrunt_runatk7 ] {ai_melee_side();};
void() axegrunt_runatk7 =[ $runattack7, axegrunt_runatk8 ] {ai_melee_side();};
void() axegrunt_runatk8 =[ $runattack8, axegrunt_runatk9 ] {ai_melee_side();};
void() axegrunt_runatk9 =[ $runattack9, axegrunt_runatk10 ] {ai_melee_side();};
void() axegrunt_runatk10 =[ $runattack10, axegrunt_runatk11 ] {ai_charge_side();};
void() axegrunt_runatk11 =[ $runattack11, axegrunt_run1 ] {ai_charge(10);};
void() axegrunt_atk1 =[ $attackb1, axegrunt_atk2 ]
{
sound (self, CHAN_WEAPON, "axegrunt/sword1.wav", 1, ATTN_NORM);
ai_charge(0);};
void() axegrunt_atk2 =[ $attackb2, axegrunt_atk3 ] {ai_charge(7);};
void() axegrunt_atk3 =[ $attackb3, axegrunt_atk4 ] {ai_charge(4);};
void() axegrunt_atk4 =[ $attackb4, axegrunt_atk5 ] {ai_charge(0);};
void() axegrunt_atk5 =[ $attackb5, axegrunt_atk6 ] {ai_charge(3);};
void() axegrunt_atk6 =[ $attackb6, axegrunt_atk7 ] {ai_charge(4); ai_melee();};
void() axegrunt_atk7 =[ $attackb7, axegrunt_atk8 ] {ai_charge(1); ai_melee();};
void() axegrunt_atk8 =[ $attackb8, axegrunt_atk9 ] {ai_charge(3);
ai_melee();};
void() axegrunt_atk9 =[ $attackb9, axegrunt_atk10] {ai_charge(1);};
void() axegrunt_atk10=[ $attackb10, axegrunt_run1 ] {ai_charge(5);};
//void() axegrunt_atk9 =[ $attack9, axegrunt_atk10 ] {};
//void() axegrunt_atk10 =[ $attack10, axegrunt_atk11 ] {};
//void() axegrunt_atk11 =[ $attack11, axegrunt_run1 ] {};
//===========================================================================
void() axegrunt_pain1 =[ $pain1, axegrunt_pain2 ] {};
void() axegrunt_pain2 =[ $pain2, axegrunt_pain3 ] {};
void() axegrunt_pain3 =[ $pain3, axegrunt_run1 ] {};
void() axegrunt_painb1 =[ $painb1, axegrunt_painb2 ] {ai_painforward(0);};
void() axegrunt_painb2 =[ $painb2, axegrunt_painb3 ] {ai_painforward(3);};
void() axegrunt_painb3 =[ $painb3, axegrunt_painb4 ] {};
void() axegrunt_painb4 =[ $painb4, axegrunt_painb5 ] {};
void() axegrunt_painb5 =[ $painb5, axegrunt_painb6 ] {ai_painforward(2);};
void() axegrunt_painb6 =[ $painb6, axegrunt_painb7 ] {ai_painforward(4);};
void() axegrunt_painb7 =[ $painb7, axegrunt_painb8 ] {ai_painforward(2);};
void() axegrunt_painb8 =[ $painb8, axegrunt_painb9 ] {ai_painforward(5);};
void() axegrunt_painb9 =[ $painb9, axegrunt_painb10 ] {ai_painforward(5);};
void() axegrunt_painb10 =[ $painb10, axegrunt_painb11 ] {ai_painforward(0);};
void() axegrunt_painb11 =[ $painb11, axegrunt_run1 ] {};
void(entity attacker, float damage) axegrunt_pain =
{
local float r;
if (self.pain_finished > time)
return;
r = random();
if (self.spawnflags & 2) // statue
sound (self, CHAN_VOICE, "statue/pain.wav", 1, ATTN_NORM);
else
sound (self, CHAN_VOICE, "axegrunt/khurt.wav", 1, ATTN_NORM);
if (r < 0.85)
{
axegrunt_pain1 ();
self.pain_finished = time + 1;
}
else
{
axegrunt_painb1 ();
self.pain_finished = time + 1;
}
};
//===========================================================================
void() axegrunt_bow1 =[ $kneel1, axegrunt_bow2 ] {ai_turn();};
void() axegrunt_bow2 =[ $kneel2, axegrunt_bow3 ] {ai_turn();};
void() axegrunt_bow3 =[ $kneel3, axegrunt_bow4 ] {ai_turn();};
void() axegrunt_bow4 =[ $kneel4, axegrunt_bow5 ] {ai_turn();};
void() axegrunt_bow5 =[ $kneel5, axegrunt_bow5 ] {ai_turn();};
void() axegrunt_bow6 =[ $kneel4, axegrunt_bow7 ] {ai_turn();};
void() axegrunt_bow7 =[ $kneel3, axegrunt_bow8 ] {ai_turn();};
void() axegrunt_bow8 =[ $kneel2, axegrunt_bow9 ] {ai_turn();};
void() axegrunt_bow9 =[ $kneel1, axegrunt_bow10 ] {ai_turn();};
void() axegrunt_bow10 =[ $walk1, axegrunt_walk1 ] {ai_turn();};
void() axegrunt_die1 =[ $death1, axegrunt_die2 ] {};
void() axegrunt_die2 =[ $death2, axegrunt_die3 ] {};
void() axegrunt_die3 =[ $death3, axegrunt_die4 ]
{self.solid = SOLID_NOT;};
void() axegrunt_die4 =[ $death4, axegrunt_die5 ] {};
void() axegrunt_die5 =[ $death5, axegrunt_die6 ] {};
void() axegrunt_die6 =[ $death6, axegrunt_die7 ] {};
void() axegrunt_die7 =[ $death7, axegrunt_die8 ] {};
void() axegrunt_die8 =[ $death8, axegrunt_die9 ] {};
void() axegrunt_die9 =[ $death9, axegrunt_die10] {};
void() axegrunt_die10=[ $death10, axegrunt_die10] {};
void() axegrunt_dieb1 =[ $deathb1, axegrunt_dieb2 ] {};
void() axegrunt_dieb2 =[ $deathb2, axegrunt_dieb3 ] {};
void() axegrunt_dieb3 =[ $deathb3, axegrunt_dieb4 ]
{self.solid = SOLID_NOT;};
void() axegrunt_dieb4 =[ $deathb4, axegrunt_dieb5 ] {};
void() axegrunt_dieb5 =[ $deathb5, axegrunt_dieb6 ] {};
void() axegrunt_dieb6 =[ $deathb6, axegrunt_dieb7 ] {};
void() axegrunt_dieb7 =[ $deathb7, axegrunt_dieb8 ] {};
void() axegrunt_dieb8 =[ $deathb8, axegrunt_dieb9 ] {};
void() axegrunt_dieb9 =[ $deathb9, axegrunt_dieb10] {};
void() axegrunt_dieb10 = [ $deathb10, axegrunt_dieb11] {};
void() axegrunt_dieb11 = [ $deathb11, axegrunt_dieb11] {};
void() axegrunt_die =
{
// check for gib
if (self.health < -40)
{
sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
ThrowHead ("progs/h_axegrunt.mdl", self.health);
if (self.spawnflags & 2) // statue
{
ThrowGib ( "progs/statgib1.mdl", self.health);
ThrowGib ( "progs/statgib2.mdl", self.health);
ThrowGib ( "progs/statgib3.mdl", self.health);
}
else
{
ThrowGib ("progs/gib1.mdl", self.health);
ThrowGib ("progs/gib2.mdl", self.health);
ThrowGib ("progs/gib3.mdl", self.health);
}
self.ammo_shells = 5;
DropBackpack();
return;
}
// regular death
if (self.spawnflags & 2) // statue
sound (self, CHAN_VOICE, "statue/death.wav", 1, ATTN_NORM);
else
sound (self, CHAN_VOICE, "axegrunt/kdeath.wav", 1, ATTN_NORM);
self.ammo_shells = 5;
DropBackpack();
if (random() < 0.5)
axegrunt_die1 ();
else
axegrunt_dieb1 ();
};
void() axegrunt_pause =
{
sound ( self, CHAN_VOICE, "statue/see.wav", 1, ATTN_NORM);
self.takedamage = DAMAGE_AIM;
self.th_stand = axegrunt_stand1;
self.th_walk = axegrunt_walk1;
self.th_run = axegrunt_run1;
self.th_melee = axegrunt_atk1;
self.th_pain = axegrunt_pain;
self.th_die = axegrunt_die;
self.use = SUB_Null;
self.think = axegrunt_run1;
self.enemy = activator;
self.nextthink = time + 0.1;
self.think = FoundTarget;
self.delay = 0;
};
void() axegrunt_pause1 =
{
self.takedamage = DAMAGE_NO;
self.use = axegrunt_pause;
self.think = axegrunt_pause1;
    self.nextthink = time + 0.1;
};
/*QUAKED monster_axegrunt (1 0 0) (-16 -16 -24) (16 16 40) Ambush Statue
Statue - select this to use the stone skin and have him frozen in place.
delay: time from sight to attack (default 5)
frame: frame to be frozen in. (default 44)
*/
void() monster_axegrunt =
{
if (deathmatch)
{
remove(self);
return;
}
precache_model ("progs/axegrunt.mdl");
precache_model ("progs/h_axegrunt.mdl");
if (self.spawnflags & 2) // statue
{
precache_model ( "progs/statgib1.mdl");
precache_model ( "progs/statgib2.mdl");
precache_model ( "progs/statgib3.mdl");
precache_sound ( "statue/see.wav");
precache_sound ( "statue/idle.wav");
precache_sound ( "statue/pain.wav");
precache_sound ( "statue/death.wav");
}
else
{
precache_sound ("axegrunt/kdeath.wav");
precache_sound ("axegrunt/khurt.wav");
precache_sound ("axegrunt/ksight.wav");
precache_sound ("axegrunt/idle.wav");
}
precache_sound ("axegrunt/sword1.wav");
precache_sound ("axegrunt/sword2.wav");
self.solid = SOLID_SLIDEBOX;
self.movetype = MOVETYPE_STEP;
setmodel (self, "progs/axegrunt.mdl");
setsize (self, '-16 -16 -24', '16 16 40');
self.health = 33;
if (self.spawnflags & 2) // statue
{
if (self.frame == 0)
self.frame = 44;
self.skin = 1;
if (!self.targetname)
{
dprint ("statue not targeted\n");
dprint (self.classname);
dprint (" at ");
dprint (vtos(self.origin));
dprint ("\n");
return;
}
self.use = axegrunt_pause;
        self.th_stand = axegrunt_pause1;
        self.th_walk = axegrunt_pause1;
self.th_run = axegrunt_pause1;
/*
        self.th_stand = axegrunt_pause1;
        self.th_walk = axegrunt_pause;
self.th_run = axegrunt_pause;
self.th_melee = axegrunt_atk1;
self.th_pain = axegrunt_pause;
self.th_die = axegrunt_die;
walkmonster_start ();
*/
}
else
{
self.th_stand = axegrunt_stand1;
self.th_walk = axegrunt_walk1;
self.th_run = axegrunt_run1;
self.th_melee = axegrunt_atk1;
self.th_pain = axegrunt_pain;
self.th_die = axegrunt_die;
walkmonster_start ();
}
};
