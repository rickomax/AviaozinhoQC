/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

// AVIÃOZINHO ---------------------------------------------------

#define STAT_CURRENT_WEAPON 32

#define WEAPON_V_AXE      1
#define WEAPON_V_SHOT     2
#define WEAPON_V_SHOT2    3
#define WEAPON_V_NAIL     4
#define WEAPON_V_LAVA     5
#define WEAPON_V_NAIL2    6
#define WEAPON_V_LAVA2    7
#define WEAPON_V_ROCK     8
#define WEAPON_V_MULTI    9
#define WEAPON_V_ROCK2    10
#define WEAPON_V_MULTI2   11
#define WEAPON_V_LIGHT    12
#define WEAPON_V_PLASMA   13

void(float id) UpdateWeaponIcon = {
	msg_entity = self; 
	WriteByte(MSG_ONE, SVC_UPDATESTAT);
	WriteByte(MSG_ONE, STAT_CURRENT_WEAPON);
	WriteLong(MSG_ONE, id);
};

// --------------------------------------------------------------

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
		UpdateWeaponIcon(WEAPON_V_AXE);
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
		UpdateWeaponIcon(WEAPON_V_SHOT);
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells1;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
		UpdateWeaponIcon(WEAPON_V_SHOT2);
	}
	else if (self.weapon == IT_LAVA_NAILGUN)
	{
		self.currentammo = self.ammo_lava_nails;
		self.weaponmodel = "progs/v_lava.mdl";
		self.weaponframe = 0;
		self.items2 = self.items2 | IT2_LAVA_NAILS;
		UpdateWeaponIcon(WEAPON_V_LAVA);
	}
	else if (self.weapon == IT_LAVA_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_lava_nails;
		self.weaponmodel = "progs/v_lava2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
		UpdateWeaponIcon(WEAPON_V_NAIL2);
	}
	else if (self.weapon == IT_MULTI_GRENADE)
	{
		self.currentammo = self.ammo_multi_rockets;
		self.weaponmodel = "progs/v_multi.mdl";
		self.weaponframe = 0;
		self.items2 = self.items2 | IT2_MULTI_ROCKETS;
		UpdateWeaponIcon(WEAPON_V_MULTI);
	}
	else if (self.weapon == IT_MULTI_ROCKET)
	{
			
		self.currentammo = self.ammo_multi_rockets;
		self.weaponmodel = "progs/v_multi2.mdl";
		self.weaponframe = 0;
		self.items2 = self.items2 | IT2_MULTI_ROCKETS;
		UpdateWeaponIcon(WEAPON_V_MULTI2);
	}
	else if (self.weapon == IT_AVIAO)
	{
		self.currentammo = self.ammo_plasma;
		self.weaponmodel = "progs/v_plasma.mdl";
		self.weaponframe = 0;
		self.items2 = self.items2 | IT2_PLASMA_AMMO;
		UpdateWeaponIcon(WEAPON_V_PLASMA);
	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails1;
		self.weaponmodel = "progs/v_nail.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
		UpdateWeaponIcon(WEAPON_V_NAIL);
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails1;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
		UpdateWeaponIcon(WEAPON_V_NAIL2);
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets1;
		self.weaponmodel = "progs/v_rock.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
		UpdateWeaponIcon(WEAPON_V_ROCK);
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets1;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
		UpdateWeaponIcon(WEAPON_V_ROCK2);
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells1;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
		UpdateWeaponIcon(WEAPON_V_LIGHT);
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
		UpdateWeaponIcon(0);
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
//avião-dash
void()  player_flame1;
void()	player_feijaoa;

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
		self.attack_finished = time + RuneApplyHell(0.393, self); // MODIFICADO: era 0.374, agora 5% mais lento
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1 ();
		W_FireSuperShotgun ();
		self.attack_finished = time + RuneApplyHell(0.549, self); // MODIFICADO: era 0.523, agora 5% mais lento
	}
	else if (self.weapon == IT_LAVA_NAILGUN)
	{
		//avião-dash
		player_flame1();
	}
	else if (self.weapon == IT_LAVA_SUPER_NAILGUN)
	{
		player_feijaoa();
		W_FireFeijao();
		self.attack_finished = time + 0.1;
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
		if((self.items & IT_LAVA_NAILGUN) && (self.weapon == IT_NAILGUN)){
			fl = IT_LAVA_NAILGUN;
			if (self.ammo_lava_nails < 1) am = 1;
		}else{
			fl = IT_NAILGUN;
			if (self.ammo_nails1 < 1) am = 1;
		}
	}
	else if (self.impulse == 5)
	{
		if ((self.items & IT_LAVA_SUPER_NAILGUN) && (self.weapon == IT_SUPER_NAILGUN)){
			fl = IT_LAVA_SUPER_NAILGUN;
			if (self.ammo_lava_nails < 2) am = 1;
		}else{
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
		if ((self.items & IT_AVIAO) && (self.weapon == IT_LIGHTNING || self.ammo_cells1 < 1))
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
		IT_AVIAO |
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
		W_ChangeWeapon();
	else if (self.impulse >= 60 && self.impulse <= 68)
		W_ChangeWeapon();
	else if (self.impulse == 9)
		CheatCommand();
	else if (self.impulse == 10)
		CycleWeaponCommand();
	else if (self.impulse == 11)
		ServerflagsCommand();
	else if (self.impulse == 12)
		CycleWeaponReverseCommand();
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
	else if (self.impulse == 255)
		QuadCheat();
	else if (self.impulse == 69)
		self.buttonuse = 1;
	
	self.impulse = 0;
};

//AVIÃOZINHO
void() PreImpulseCommands =
{
	if(self.impulse == 40) PlayerDoubleJump();
	if(self.impulse == 41) PlayerDash();
	
	if(self.impulse == 42) AV_SwitchCam();
	if(self.impulse == 43) AV_SwitchSkate();
	
	if(self.impulse >= 40 && self.impulse <= 50) self.impulse = 0;
}

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{

	if (self.impulse) PreImpulseCommands();

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
	
	// AVIÃO
	// Botões de "use"
	local entity oldself;
	oldself = self;
	vector start, end;
	traceline(self.origin + '0 0 22', self.origin + v_forward * 128, 0, self);
	if (trace_ent && trace_ent.useractivate) 
	{
		if (!trace_ent.using) {
			centerprint(self, "$button_press");
		}
		if (self.buttonuse)
		{
			other = self;
			self = trace_ent;
			trace_ent.enemy = other;
			trace_ent.useractivate();
		}
	}
	self = oldself;
	self.buttonuse = 0;
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
