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
==============================================================================

SWORD

==============================================================================
*/

$cd /qwork/xpack/models/sword
$origin 0 0 24
$base base
$skin badass3

$frame stand1
//$stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame runb1 runb2 runb3 runb4 runb5 runb6 runb7 runb8

//frame runc1 runc2 runc3 runc4 runc5 runc6

//$frame runattack1 runattack2 runattack3 runattack4 runattack5
//$frame runattack6 runattack7 runattack8 runattack9 runattack10
//$frame runattack11

//$frame pain1 pain2 pain3

//$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9
//$frame painb10 painb11

//frame attack1 attack2 attack3 attack4 attack5 attack6 attack7
//frame attack8 attack9 attack10 attack11

$frame attackb1 attackb2 attackb3 attackb4 attackb5
$frame attackb6 attackb7 attackb8 attackb9 attackb10

//$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
//$frame walk10 walk11 walk12 walk13 walk14

//$frame kneel1 kneel2 kneel3 kneel4 kneel5

//$frame standing2 standing3 standing4 standing5

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9 deathb10 deathb11

void() sword_stand1 = [ $stand1, sword_stand1 ] { ai_stand(); };

// AVIÃOZINHO: SMALLER DELAY BETWEEN MOVEMENT TRANSITIONS
void() sword_run1 = [ $runb1, sword_run2 ] { ai_run(14); };
void() sword_run2 = [ $runb2, sword_run3 ] { ai_run(14); };
void() sword_run3 = [ $runb3, sword_run4 ] { ai_run(14); };
void() sword_run4 = [ $runb4, sword_run5 ] { ai_run(14); };
void() sword_run5 = [ $runb5, sword_run6 ] { ai_run(14); };
void() sword_run6 = [ $runb6, sword_run7 ] { ai_run(14); };
void() sword_run7 = [ $runb7, sword_run8 ] { ai_run(14); };
void() sword_run8 = [ $runb8, sword_run1 ] { ai_run(14); };

void() sword_atk1 = [ $attackb1, sword_atk2 ] { sound(self, 0, "knight/sword1.wav", 1, 1); ai_charge(14); };
void() sword_atk2 = [ $attackb2, sword_atk3 ] { ai_charge(14); };
void() sword_atk3 = [ $attackb3, sword_atk4 ] { ai_charge(14); };
void() sword_atk4 = [ $attackb4, sword_atk5 ] { ai_charge(14); };
void() sword_atk5 = [ $attackb5, sword_atk6 ] { ai_melee(); };
void() sword_atk6 = [ $attackb6, sword_atk7 ] { ai_melee(); };
void() sword_atk7 = [ $attackb7, sword_atk8 ] { ai_melee(); };
void() sword_atk8 = [ $attackb8, sword_atk9 ] { ai_charge(14); };
void() sword_atk9 = [ $attackb9, sword_atk10 ] { ai_charge(14); };
void() sword_atk10 = [ $attackb10, sword_run1 ] { ai_charge(14); };

//===========================================================================

void() sword_die1 = [ $death1, sword_die2 ] {};
void() sword_die2 = [ $death2, sword_die3 ] {};
void() sword_die3 = [ $death3, sword_die4 ] {self.solid = SOLID_NOT;self.ammo_nails = 5;DropBackpack();};
void() sword_die4 = [ $death4, sword_die5 ] {};
void() sword_die5 = [ $death5, sword_die6 ] {};
void() sword_die6 = [ $death6, sword_die7 ] {};
void() sword_die7 = [ $death7, sword_die8 ] { sound(self, 1, "player/axhit2.wav", 0.5, ATTN_NORM); };
void() sword_die8 = [ $death8, sword_die9 ] {};
void() sword_die9 = [ $death9, sword_die10 ] {};
void() sword_die10 = [ $death10, sword_die10 ] {};

void() sword_dieb1 = [ $deathb1, sword_dieb2 ] {};
void() sword_dieb2 = [ $deathb2, sword_dieb3 ] {};
void() sword_dieb3 = [ $deathb3, sword_dieb4 ] {self.solid = SOLID_NOT;self.ammo_nails = 8;DropBackpack();ai_back(4);};
void() sword_dieb4 = [ $deathb4, sword_dieb5 ] {};
void() sword_dieb5 = [ $deathb5, sword_dieb6 ] {};
void() sword_dieb6 = [ $deathb6, sword_dieb7 ] {};
void() sword_dieb7 = [ $deathb7, sword_dieb8 ] { sound(self, 1, "player/axhit2.wav", 0.5, ATTN_NORM); };
void() sword_dieb8 = [ $deathb8, sword_dieb9 ] {};
void() sword_dieb9 = [ $deathb9, sword_dieb10 ] {};
void() sword_dieb10 = [ $deathb10, sword_dieb11 ] {};
void() sword_dieb11 = [ $deathb11, sword_dieb11 ] {};

void() sword_die =
{


// check for gib
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_guard.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}


    // regular death
    self.effects = 0;
    if (random() < 0.5)
        sword_die1 ();
    else
        sword_dieb1 ();
};

void() sword_pause =
{
    // Removido qualquer delay para que a detecção e transição aconteçam instantaneamente
    self.th_run = sword_run1;
    self.think = sword_run1;
    self.nextthink = time + 0.1;  // Tempo de detecção reduzido para 0.1
    self.delay = 0;
};

void() sword_pain =
{
    self.th_run = sword_run1;
    self.think = sword_run1;
    self.nextthink = time + 0.1;  // Tempo de detecção reduzido para 0.1
    self.delay = 0;
    self.th_pain = SUB_Null;
};

/*QUAKED monster_sword (1 0 0) (-16 -16 -24) (16 16 40) Ambush
The Invisible Swordsman

delay - seconds after first sighting before it attacks (default 10)
*/
void() monster_sword =
{
    if (deathmatch)
    {
        remove(self);
        return;
    }

    precache_model("progs/sword.mdl");
    precache_model("progs/h_guard.mdl");

    precache_sound("knight/sword1.wav");
    precache_sound("knight/ksight.wav");
    precache_sound("player/axhit2.wav");

    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_STEP;

    setmodel(self, "progs/sword.mdl");

    setsize(self, '-16 -16 -24', '16 16 40');
    self.health = 25;  // Adjusted to 25 health as requested

    if (!self.delay)
        self.delay = 0.1;  // Delay set to 0.1 so detection is almost instantaneous

    self.th_stand = sword_stand1;
    self.th_walk = sword_stand1;
    self.th_run = sword_pause;
    self.th_melee = sword_atk1;
    self.th_die = sword_die;
    self.th_pain = sword_pain;

    walkmonster_start();
};
