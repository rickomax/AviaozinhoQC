// ==========================================================================
//                                CYBERDEMON
//
// Original code and models by Marc Fontaine
// Modified for the Ultimate Weapons Mod by Andy Brennan
// ==========================================================================

$origin 0 0 64
$base base     
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7

$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6 shoot7 shoot8

//=============================================================================
void() CyberFireRLG =
{
 local vector org,dir;
local	entity	en;
 		
self.effects = self.effects | EF_MUZZLEFLASH;
org = self.origin + '0 0 16';
en = self.enemy;
	sound (self, CHAN_WEAPON, "weapons/lstart.wav", 1, ATTN_NORM);
	dir = en.origin - en.velocity*0.1;
	
	dir = normalize (dir - org);

	traceline (org, self.origin + dir* 750, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING3);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
   
	LightningDamage (org, trace_endpos, self, 1);
  
};


void(float xco, float yco, float zco) SpawnExplosion;

/*
=====================
CyberDemonFireMissile
=====================
*/
void() CyberDemonFireMissile =
{
   local entity missile;
   local vector org;
   
   self.effects = self.effects | EF_MUZZLEFLASH;

   sound (self, CHAN_WEAPON, "cyber/cybfire.wav", 1, ATTN_NORM);

   missile = spawn ();
   missile.owner = self;
   missile.movetype = MOVETYPE_FLYMISSILE;
   missile.solid = SOLID_BBOX;
      
// set missile speed 

   makevectors (self.angles);

   org = self.origin + '0 0 30' + (v_right * -5);
   missile.velocity = normalize((self.enemy.origin + '0 0 1') - org);
   missile.velocity = missile.velocity * 10;

   missile.angles = vectoangles(missile.velocity);
   
   missile.touch = T_MissileTouch;
   
// set missile duration
   missile.nextthink = time + 0.5;
   missile.think = SUB_Remove;

   setmodel  (missile, "progs/cmissile.mdl");
   setsize   (missile, '0 0 0', '0 0 0');
   setorigin (missile, self.origin + '0 0 30' + (v_right * -22) );
};

void(float offset) CyberMissile =
{ 
    local   vector  offang; 
    local   vector  org, vec; 
        self.effects = self.effects | EF_MUZZLEFLASH;
	offang = vectoangles (self.enemy.origin - self.origin);
	offang_y = offang_y + offset * 3;
	
	makevectors (offang);

	org = self.origin - 15*normalize(self.velocity);

// set missile speed
	vec = normalize (v_forward);
	vec_z = 0 - vec_z + (random() - 0.1)*0.1;
	
	launch_spike (org, vec);
	newmis.classname = "LaunchNails";
	setmodel (newmis, "progs/missile.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	newmis.velocity = vec*300;
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

};

void() CyberhMissileTouch;
void() CyberhHome;
void() CyberhMissile =
{
	local	entity 	missile;
	local	float	dist, flytime;
    local	vector	offang;
	local	vector	org, vec;
	
	offang = vectoangles (self.enemy.origin - self.origin);
	offang_y = offang_y ;

	
	makevectors (offang);

	org = self.origin + self.mins + self.size*0.1 + v_forward * 1;


	dist = vlen (self.enemy.origin - self.origin);
	flytime = dist * 0.002;
	if (flytime < 0.1)
		flytime = 0.1;

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "cyber/cyjump.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;

       vec = normalize (v_forward);
	vec_z = 0 - vec_z + (random() - 0.1)*0.1;


	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setmodel (missile, "progs/w_ball.mdl");

	setsize (missile, '0 0 0', '0 0 0');		

	missile.origin = self.origin + '0 0 1';
	missile.velocity = vec * 100;
	missile.avelocity = '200 200 200';
	missile.nextthink = flytime + time;
	missile.think = CyberhHome;
	missile.enemy = self.enemy;
	missile.touch = CyberhMissileTouch;
};

void() CyberhHome =
{
	local vector	dir, vtemp;
	vtemp = self.enemy.origin + '0 0 1';
	if (self.enemy.health < 1)
	{
		remove(self);
		return;
	}
	dir = normalize(vtemp - self.origin);
	if (skill == 3)
		self.velocity = dir * 100;
	else
		self.velocity = dir * 450;
	self.nextthink = time + 0.3;
	self.think = CyberhHome;	
};

void() CyberhMissileTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner

	if (other.classname == "monster_zombie")
		T_Damage (other, self, self, 5);	
	T_RadiusDamage (self, self.owner, 5, world);
	

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};


void() cyber_missile21; // To make jumping to last frames possible

void() cyber_missile1  =[ $shoot1,     cyber_missile2  ] {ai_face();};
void() cyber_missile2  =[ $shoot2,     cyber_missile3  ] {ai_face();CyberFireRLG();};
void() cyber_missile3  =[ $shoot3,     cyber_missile4  ]
{
   ai_face();
   makevectors (self.angles);
   traceline (self.origin + '0 0 30' + v_right * -5, self.enemy.origin + '0 0 1', FALSE, self);
   if (trace_ent != self.enemy)
      cyber_missile21 ();
   if (self.enemy.health <= 0)
      cyber_missile21 ();
};
void() cyber_missile4  =[ $shoot4,     cyber_missile5  ] {ai_face();CyberDemonFireMissile();};
void() cyber_missile5  =[ $shoot5,     cyber_missile6  ] {ai_face();CyberMissile(0);};
void() cyber_missile6  =[ $shoot6,     cyber_missile7  ] {ai_face();CyberMissile(1);CyberMissile(-1);CyberMissile(1);CyberMissile(-1);};
void() cyber_missile7  =[ $shoot7,     cyber_missile8  ] {ai_face();CyberMissile(8);CyberMissile(-8);CyberMissile(3);CyberMissile(-3);};
void() cyber_missile8  =[ $shoot8,     cyber_missile9  ] {ai_face();};
void() cyber_missile9  =[ $shoot3,     cyber_missile10 ] 
{
   ai_face();
   makevectors (self.angles);
   traceline (self.origin + '0 0 30' + v_right * -5, self.enemy.origin + '0 0 1', FALSE, self);
   if (trace_ent != self.enemy)
      cyber_missile21 ();
   if (self.enemy.health <= 0)
      cyber_missile21 ();
};
void() cyber_missile10 =[ $shoot4,     cyber_missile11 ] {ai_face();CyberDemonFireMissile();};
void() cyber_missile11 =[ $shoot5,     cyber_missile12 ] {ai_face();CyberMissile(1);CyberMissile(-1);};
void() cyber_missile12 =[ $shoot6,     cyber_missile13 ] {ai_face();CyberMissile(-1);CyberMissile(1);CyberMissile(0);CyberMissile(-1);};
void() cyber_missile13 =[ $shoot7,     cyber_missile14 ] {ai_face();CyberMissile(-4);CyberMissile(4);CyberMissile(1);CyberMissile(-1);};
void() cyber_missile14 =[ $shoot8,     cyber_missile15 ] {ai_face();};
void() cyber_missile15 =[ $shoot3,     cyber_missile16 ]
{
   ai_face();
   makevectors (self.angles);
   traceline (self.origin + '0 0 30' + v_right * -5, self.enemy.origin + '0 0 1', FALSE, self);
   if (trace_ent != self.enemy)
      cyber_missile21 ();
   if (self.enemy.health <= 0)
      cyber_missile21 ();
};
void() cyber_missile16 =[ $shoot4,     cyber_missile17 ] {ai_face();CyberDemonFireMissile();};
void() cyber_missile17 =[ $shoot5,     cyber_missile18 ] {ai_face();CyberMissile(1);CyberMissile(-1);};
void() cyber_missile18 =[ $shoot6,     cyber_missile19 ] {ai_face();CyberMissile(-3);CyberMissile(3);CyberMissile(1);CyberMissile(-1);};
void() cyber_missile19 =[ $shoot7,     cyber_missile20 ] {ai_face();CyberMissile(1);CyberMissile(-1);CyberMissile(1);CyberMissile(-1);};
void() cyber_missile20 =[ $shoot8,     cyber_missile21 ] {ai_face();CyberMissile(-1);CyberMissile(1);};
void() cyber_missile21 =[ $shoot3,     cyber_missile22 ] {ai_face();CyberMissile(0);};
void() cyber_missile22 =[ $shoot2,     cyber_missile23 ] {ai_face();};
void() cyber_missile23 =[ $shoot1,     cyber_run1 ]
{
   ai_face();
};

void() cyber_hmissile1  =[ $shoot1,     cyber_hmissile2  ] {ai_face();};
void() cyber_hmissile2  =[ $shoot2,     cyber_hmissile3  ] {ai_face();};
void() cyber_hmissile3  =[ $shoot3,     cyber_hmissile4  ]
{
   ai_face();
   makevectors (self.angles);
   traceline (self.origin + '0 0 5' + v_right * -5, self.enemy.origin + '0 0 1', FALSE, self);
   if (trace_ent != self.enemy)
      cyber_missile21 ();
   if (self.enemy.health <= 0)
      cyber_missile21 ();
};
void() cyber_hmissile4  =[ $shoot4,     cyber_hmissile5  ] {ai_face();};
void() cyber_hmissile5  =[ $shoot5,     cyber_hmissile6  ] {ai_face();CyberhMissile();};
void() cyber_hmissile6  =[ $shoot6,     cyber_hmissile7  ] {ai_face();CyberhMissile();CyberhMissile();};
void() cyber_hmissile7  =[ $shoot7,     cyber_hmissile8  ] {ai_face();CyberhMissile();CyberhMissile();};
void() cyber_hmissile8  =[ $shoot8,     cyber_hmissile9  ] {ai_face();};
void() cyber_hmissile9  =[ $shoot3,     cyber_hmissile10 ] 
{
   ai_face();
   makevectors (self.angles);
   traceline (self.origin + '0 0 5' + v_right * -5, self.enemy.origin + '0 0 1', FALSE, self);
   if (trace_ent != self.enemy)
      cyber_missile21 ();
   if (self.enemy.health <= 0)
      cyber_missile21 ();
};
void() cyber_hmissile10 =[ $shoot4,     cyber_hmissile11 ] {ai_face();};
void() cyber_hmissile11 =[ $shoot5,     cyber_hmissile12 ] {ai_face();CyberhMissile();CyberhMissile();};
void() cyber_hmissile12 =[ $shoot6,     cyber_hmissile13 ] {ai_face();CyberhMissile();CyberhMissile();};
void() cyber_hmissile13 =[ $shoot7,     cyber_hmissile14 ] {ai_face();CyberhMissile();CyberhMissile();};
void() cyber_hmissile14 =[ $shoot8,     cyber_hmissile15 ] {ai_face();};
void() cyber_hmissile15 =[ $shoot3,     cyber_hmissile16 ]
{
   ai_face();
   makevectors (self.angles);
   traceline (self.origin + '0 0 5' + v_right * -5, self.enemy.origin + '0 0 1', FALSE, self);
   if (trace_ent != self.enemy)
      cyber_missile21 ();
   if (self.enemy.health <= 0)
      cyber_missile21 ();
};
void() cyber_hmissile16 =[ $shoot4,     cyber_hmissile17 ] {ai_face();};
void() cyber_hmissile17 =[ $shoot5,     cyber_hmissile18 ] {ai_face();CyberhMissile();CyberhMissile();};
void() cyber_hmissile18 =[ $shoot6,     cyber_hmissile19 ] {ai_face();CyberhMissile();CyberhMissile();};
void() cyber_hmissile19 =[ $shoot7,     cyber_hmissile20 ] {ai_face();};
void() cyber_hmissile20 =[ $shoot8,     cyber_hmissile21 ] {ai_face();};
void() cyber_hmissile21 =[ $shoot3,     cyber_hmissile22 ] {ai_face();};
void() cyber_hmissile22 =[ $shoot2,     cyber_hmissile23 ] {ai_face();};
void() cyber_hmissile23 =[ $shoot1,     cyber_run1 ]
{
   ai_face();
};

void() cyber_lmissile1  =[ $shoot1,     cyber_lmissile2  ] {ai_face();};
void() cyber_lmissile2  =[ $shoot2,     cyber_lmissile3  ] {ai_face();};
void() cyber_lmissile3  =[ $shoot3,     cyber_lmissile4  ]
{
   ai_face();
   makevectors (self.angles);
   traceline (self.origin + '0 0 5' + v_right * -5, self.enemy.origin + '0 0 1', FALSE, self);
   if (trace_ent != self.enemy)
      cyber_missile21 ();
   if (self.enemy.health <= 0)
      cyber_missile21 ();
};
void() cyber_lmissile4  =[ $shoot4,     cyber_lmissile5  ] {ai_face();CyberFireRLG();};
void() cyber_lmissile5  =[ $shoot5,     cyber_lmissile6  ] {ai_face();hknight_shot(-1);hknight_shot(-1);hknight_shot(-15);hknight_shot(-1);hknight_shot(-1);hknight_shot(-30);hknight_shot(-35);hknight_shot(-40);hknight_shot(35);hknight_shot(30);hknight_shot(1);hknight_shot(1);hknight_shot(15);hknight_shot(1);hknight_shot(1);hknight_shot(0);};
void() cyber_lmissile6  =[ $shoot6,     cyber_lmissile7  ] {ai_face();hknight_shot(-3);hknight_shot(-7);hknight_shot(-13);hknight_shot(-17);hknight_shot(-23);hknight_shot(-27);hknight_shot(-33);hknight_shot(-37);hknight_shot(32);hknight_shot(28);hknight_shot(22);hknight_shot(18);hknight_shot(12);hknight_shot(8);hknight_shot(3);hknight_shot(1);};
void() cyber_lmissile7  =[ $shoot7,     cyber_lmissile8  ] {ai_face();hknight_shot(-1);hknight_shot(-1);hknight_shot(-15);hknight_shot(-1);hknight_shot(-1);hknight_shot(-30);hknight_shot(-35);hknight_shot(-40);hknight_shot(35);hknight_shot(30);hknight_shot(1);hknight_shot(1);hknight_shot(15);hknight_shot(1);hknight_shot(1);hknight_shot(0);};
void() cyber_lmissile8  =[ $shoot8,     cyber_lmissile9  ] {ai_face();};
void() cyber_lmissile9  =[ $shoot3,     cyber_lmissile10 ] 
{
   ai_face();
   makevectors (self.angles);
   traceline (self.origin + '0 0 5' + v_right * -5, self.enemy.origin + '0 0 1', FALSE, self);
   if (trace_ent != self.enemy)
      cyber_missile21 ();
   if (self.enemy.health <= 0)
      cyber_missile21 ();
};
void() cyber_lmissile10 =[ $shoot4,     cyber_lmissile11 ] {ai_face();CyberFireRLG();};
void() cyber_lmissile11 =[ $shoot5,     cyber_lmissile12 ] {ai_face();hknight_shot(-3);hknight_shot(-7);hknight_shot(-1);hknight_shot(-17);hknight_shot(-23);hknight_shot(-2);hknight_shot(-3);hknight_shot(-3);hknight_shot(32);hknight_shot(28);hknight_shot(22);hknight_shot(1);hknight_shot(1);hknight_shot(8);hknight_shot(3);hknight_shot(1);};
void() cyber_lmissile12 =[ $shoot6,     cyber_lmissile13 ] {ai_face();CyberFireRLG();};
void() cyber_lmissile13 =[ $shoot7,     cyber_lmissile14 ] {ai_face();hknight_shot(-3);hknight_shot(-7);hknight_shot(-13);hknight_shot(-1);hknight_shot(-2);hknight_shot(-2);hknight_shot(-3);hknight_shot(-3);hknight_shot(3);hknight_shot(2);hknight_shot(2);hknight_shot(1);hknight_shot(12);hknight_shot(8);hknight_shot(3);hknight_shot(1);};
void() cyber_lmissile14 =[ $shoot8,     cyber_lmissile15 ] {ai_face();};
void() cyber_lmissile15 =[ $shoot3,     cyber_lmissile16 ]
{
   ai_face();
   makevectors (self.angles);
   traceline (self.origin + '0 0 30' + v_right * -22, self.enemy.origin + '0 0 1', FALSE, self);
   if (trace_ent != self.enemy)
      cyber_missile21 ();
   if (self.enemy.health <= 0)
      cyber_missile21 ();
};
void() cyber_lmissile16 =[ $shoot4,     cyber_lmissile17 ] {ai_face();};
void() cyber_lmissile17 =[ $shoot5,     cyber_lmissile18 ] {ai_face();CyberFireRLG();};
void() cyber_lmissile18 =[ $shoot6,     cyber_lmissile19 ] {ai_face();hknight_shot(-3);hknight_shot(-7);hknight_shot(-13);hknight_shot(-17);hknight_shot(-23);hknight_shot(-27);hknight_shot(-33);hknight_shot(-37);hknight_shot(32);hknight_shot(28);hknight_shot(22);hknight_shot(18);hknight_shot(12);hknight_shot(8);hknight_shot(3);hknight_shot(1);};
void() cyber_lmissile19 =[ $shoot7,     cyber_lmissile20 ] {ai_face();hknight_shot(-1);hknight_shot(-1);hknight_shot(-15);hknight_shot(-1);hknight_shot(-1);hknight_shot(-30);hknight_shot(-35);hknight_shot(-40);hknight_shot(35);hknight_shot(30);hknight_shot(1);hknight_shot(1);hknight_shot(15);hknight_shot(1);hknight_shot(1);hknight_shot(0);};
void() cyber_lmissile20 =[ $shoot8,     cyber_lmissile21 ] {ai_face();hknight_shot(-3);hknight_shot(-7);hknight_shot(-13);hknight_shot(-17);hknight_shot(-23);hknight_shot(-27);hknight_shot(-33);hknight_shot(-37);hknight_shot(32);hknight_shot(28);hknight_shot(22);hknight_shot(18);hknight_shot(12);hknight_shot(8);hknight_shot(3);hknight_shot(1);};
void() cyber_lmissile21 =[ $shoot3,     cyber_lmissile22 ] {ai_face();CyberFireRLG();};
void() cyber_lmissile22 =[ $shoot2,     cyber_lmissile23 ] {ai_face();};
void() cyber_lmissile23 =[ $shoot1,     cyber_run1 ]
{
   ai_face();
};


void() cyber_attack =
 {      
       if(random()>0.1)
               cyber_missile1 ();
       else if(random()>0.1)
               cyber_hmissile1 ();
         else
               cyber_lmissile1 ();
 };


//=============================================================================

void() cyber_stand1   =[ $stand1, cyber_stand1 ] {ai_stand();};

// walk

void() cyber_walk1 =[ $walk1,     cyber_walk2  ] {ai_walk(8);};
void() cyber_walk2 =[ $walk2,     cyber_walk3  ] {ai_walk(7);};
void() cyber_walk3 =[ $walk3,     cyber_walk4  ] 
   {  ai_walk(7);
      sound (self, CHAN_WEAPON, "cyber/cybmet.wav", 1, ATTN_NORM);
   };
void() cyber_walk4 =[ $walk4,     cyber_walk5  ] {ai_walk(7);};
void() cyber_walk5 =[ $walk5,     cyber_walk6  ] 
   {  ai_walk(7);
      sound (self, CHAN_WEAPON, "cyber/cybhoof.wav", 1, ATTN_NORM);
   };
void() cyber_walk6 =[ $walk6,     cyber_walk7  ] {ai_walk(9);};
void() cyber_walk7 =[ $walk7,     cyber_walk1  ] {ai_walk(8);};

// run (same as walk really, just a little faster)

void() cyber_run1 =[ $walk1,     cyber_run2  ] {ai_run(13);};
void() cyber_run2 =[ $walk2,     cyber_run3  ] {ai_run(12);};
void() cyber_run3 =[ $walk3,     cyber_run4  ] 
   {  ai_run(12);
      sound (self, CHAN_WEAPON, "cyber/cybmet.wav", 1, ATTN_NORM);
   };
void() cyber_run4 =[ $walk4,     cyber_run5  ] {ai_run(12);};
void() cyber_run5 =[ $walk5,     cyber_run6  ] 
   {
      sound (self, CHAN_WEAPON, "cyber/cybhoof.wav", 1, ATTN_NORM);
      ai_run(12);
   };
void() cyber_run6 =[ $walk6,     cyber_run7  ] {ai_run(15);};
void() cyber_run7 =[ $walk7,     cyber_run1  ] {ai_run(13);};


// void() cyber_pain1;
// A Cyberdemon doesn't show pain!

/////////////////////////////////////////////////////////

void(entity attacker, float damage) cyber_pain =
{
// don't make multiple pain sounds right after each other
   if (self.pain_finished > time)
      return;

   if (random() < 0.1)
      sound (self, CHAN_VOICE, "cyber/cybpain.wav", 1, ATTN_NORM);    

   if (self.flags )
        self.pain_finished = time + 3;
   else
        self.pain_finished = time + 1;

};


void()   cyber_die1   =[ $walk1, cyber_die2   ] 
   { 
      sound (self, 7, "cyber/cybdie.wav", 1, ATTN_NORM);
      ai_pain(3);
   };
void()   cyber_die2   =[ $walk2, cyber_die3   ] {ai_pain(3);};
void()   cyber_die3   =[ $walk3, cyber_die4   ] {ai_pain(3);};
void()   cyber_die4   =[ $walk4, cyber_die5   ] {ai_pain(3);};
void()   cyber_die5   =[ $walk5, cyber_die6   ] {ai_pain(3);};
void()   cyber_die6   =[ $walk6, cyber_die7   ] {ai_pain(3);};
void()   cyber_die7   =[ $walk7, cyber_die8   ] {ai_pain(3);};
void()   cyber_die8   =[ $walk1, cyber_die9   ] 
   {
     ai_pain(3);
     sound (self, 1, "cyber/servo.wav", 1, ATTN_NORM);
   };
void()   cyber_die9   =[ $shoot1, cyber_die10   ] 
   { ai_pain(3);
     SpawnExplosion (self.origin_x, self.origin_y + 1, self.origin_z + 60);
     sound (self, 1, "weapons/r_exp3.wav", 0.4, ATTN_NORM);
   };
void()   cyber_die10   =[ $shoot2, cyber_die11  ] {ai_pain(3);};
void()   cyber_die11   =[ $shoot2, cyber_die12   ] 
   { ai_pain(3);
     SpawnExplosion (self.origin_x, self.origin_y - 1, self.origin_z + 40);
     sound (self, 1, "weapons/r_exp3.wav", 0.4, ATTN_NORM);
   };
void()   cyber_die12   =[ $shoot3, cyber_die13   ]
   { sound (self, CHAN_VOICE, "cyber/cybdie.wav", 1, ATTN_NORM);
     ai_pain(3);
   };
void()   cyber_die13   =[ $shoot3, cyber_die14   ] 
   { sound (self, 3, "weapons/r_exp3.wav", 0.4, ATTN_NORM);
     SpawnExplosion (self.origin_x - 1, self.origin_y, self.origin_z+1);
     SpawnExplosion (self.origin_x + 1, self.origin_y, self.origin_z+1);
     SpawnExplosion (self.origin_x, self.origin_y - 1, self.origin_z+1);
     SpawnExplosion (self.origin_x, self.origin_y + 1, self.origin_z+1);
     ai_pain(3);
   };
void()   cyber_die14   =[ $shoot3, cyber_die15   ]  {ai_pain(3);};
void()   cyber_die15   =[ $shoot2, cyber_die16   ] 
   { SpawnExplosion (self.origin_x - 1, self.origin_y, self.origin_z+40);
     SpawnExplosion (self.origin_x + 1, self.origin_y, self.origin_z+40);
     SpawnExplosion (self.origin_x, self.origin_y - 1, self.origin_z+40);
     SpawnExplosion (self.origin_x, self.origin_y + 1, self.origin_z+40);
     ai_pain(1);
   };
void()   cyber_die16   =[ $shoot2, cyber_die17   ] {ai_pain(3);};
void()   cyber_die17   =[ $shoot3, cyber_die18   ] 
   { ai_pain(1);
     SpawnExplosion (self.origin_x - 1, self.origin_y, self.origin_z+70);
     SpawnExplosion (self.origin_x + 1, self.origin_y, self.origin_z+70);
     SpawnExplosion (self.origin_x, self.origin_y - 1, self.origin_z+70);
     SpawnExplosion (self.origin_x, self.origin_y + 1, self.origin_z+70);
   };
void()   cyber_die18   =[ $shoot3, SUB_Remove   ] 
   {
      SpawnExplosion (self.origin_x - 1, self.origin_y, self.origin_z+40);
      SpawnExplosion (self.origin_x + 1, self.origin_y, self.origin_z+40);
      SpawnExplosion (self.origin_x, self.origin_y - 1, self.origin_z+40);
      SpawnExplosion (self.origin_x, self.origin_y + 1, self.origin_z+40);
      sound (self, 4, "weapons/r_exp3.wav", 1, ATTN_NORM);
      sound (self, 1, "cyber/boom.wav", 1, ATTN_NORM);
      ThrowHead ("progs/h_cyber.mdl", -1 - (random()*1) );
      ThrowGib ("progs/gib3.mdl", -150 - (random()*1) );
      ThrowGib ("progs/gib3.mdl", -1 - (random()*1) );
      ThrowGib ("progs/gib1.mdl", -150 - (random()*1) );
      ThrowGib ("progs/gib3.mdl", -1 - (random()*1) );
      ThrowGib ("progs/gib3.mdl", -70 - (random()*1) );
      ThrowGib ("progs/gib3.mdl", -1 - (random()*1) );
      return; 
   };

void() cyber_die =
{
   cyber_die1 ();
};


/*QUAKED monster_cyber (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_cyber =
{
   if (deathmatch)
   {
          remove(self);
          return;
         }
   precache_model ("progs/cyber.mdl");
   precache_model ("progs/h_cyber.mdl");
   precache_model ("progs/missile.mdl");
   precache_model ("progs/w_ball.mdl");
   precache_model ("progs/hrail.mdl");
   precache_model ("progs/k_spike.mdl");
   precache_model ("progs/cmissile.mdl");


   precache_sound ("cyber/cybsee.wav");
   precache_sound ("cyber/cybdie.wav");
   precache_sound ("cyber/cybhoof.wav");
   precache_sound ("cyber/cybpain.wav");
   precache_sound ("cyber/cybmet.wav");
   precache_sound ("cyber/cybfire.wav");
   precache_sound ("cyber/boom.wav");
   precache_sound ("cyber/servo.wav");
   precache_sound ("cyber/cyjump.wav");
   precache_sound ("hknight/rail.wav");


   self.solid    = SOLID_SLIDEBOX;
   self.movetype = MOVETYPE_STEP;

   setmodel (self, "progs/cyber.mdl");

  setsize (self, '-16 -16 -24', '16 16 40');
   
   if(skill ==3)
   	self.health = 4000; // Approximately the Daikon health...
   else
	self.health = 4000; // Approximately the Daikon health...
   
   self.classname = "monster_cyber";
   self.th_stand   = cyber_stand1;
   self.th_walk    = cyber_walk1;
   self.th_run     = cyber_run1;
   self.th_die     = cyber_die;
   self.th_melee = cyber_attack;
   self.th_missile = cyber_attack;
   self.th_pain    = cyber_pain;
   
   walkmonster_start();
};



// ======= Implementações mínimas adicionadas =======

void() qogre_MissileTouch = {
    dprint("qogre_MissileTouch chamado\n");
};

void(float xco, float yco, float zco) SpawnExplosion = {
    dprint("SpawnExplosion chamado\n");
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_EXPLOSION);
    WriteCoord(MSG_BROADCAST, xco);
    WriteCoord(MSG_BROADCAST, yco);
    WriteCoord(MSG_BROADCAST, zco);
};

// ================================================
