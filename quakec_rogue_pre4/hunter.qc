/*
==============================================================================
Hunter
Simplified to shoot rockets with custom touch function, faithful to Quake.
Uses hunter_rocket_touch for reduced damage (4-8 direct, 5 radius, 20% of original).
Implements 2-second cooldown and movement between shots using last_attack.
Focuses on idle, walk, run, fire, and death with minimal frames.
Uses fallback models/sounds (soldier.mdl, h_guard.mdl, gibs).
==============================================================================
*/

// Forward declarations
void() hunter_shoot;
void() hunter_explode;
void() hunter_run1;
void() hunter_fire1;
void() hunter_die1;
void() hunter_rocket_touch;

$cd id1/models/hunter
$origin 0 0 24
$base base
$skin skin
$frame run1 run2 run3 run4 run5
$frame fire1 fire2 fire3
$frame die1 die2 die3
$frame idle1 idle2 idle3
$frame walk1 walk2 walk3 walk4 walk5

//==========================================================
float last_attack; // Local variable to track last attack time, no entity field

void() hunter_rocket_touch =
{
    if (other == self.owner)
        return; // don't explode on owner
    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }
    local float damg = 4 + random() * 4; // Reduced to 20% of original (4-8 damage)
    sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_EXPLOSION);
    WriteCoord(MSG_BROADCAST, self.origin_x);
    WriteCoord(MSG_BROADCAST, self.origin_y);
    WriteCoord(MSG_BROADCAST, self.origin_z);
    if (other.health)
    {
        T_Damage(other, self, self.owner, damg);
    }
    T_RadiusDamage(self, self.owner, 5, other); // Reduced to 20% of original (5 radius)
    remove(self);
};

void() hunter_shoot =
{
    local vector org, vec;
    makevectors(self.angles);
    org = self.origin + v_forward * 20 + '0 0 24';
    sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
    self.effects = self.effects | EF_MUZZLEFLASH;
    vec = self.enemy.origin - org;
    vec = normalize(vec);
    local entity missile;
    missile = spawn();
    missile.owner = self;
    missile.movetype = MOVETYPE_FLYMISSILE;
    missile.solid = SOLID_BBOX;
    missile.classname = "missile";
    missile.velocity = vec * 1000; // Match W_FireRocket speed
    missile.angles = vectoangles(missile.velocity);
    missile.touch = hunter_rocket_touch; // Use custom touch function
    missile.nextthink = time + 5;
    missile.think = SUB_Remove;
    setmodel(missile, "progs/missile.mdl");
    setsize(missile, '0 0 0', '0 0 0');
    setorigin(missile, org);
    last_attack = time; // Update last attack time
};

// Idle
void() hunter_idle1 =[ $idle1, hunter_idle2 ] {ai_stand(); if (random() < 0.2) sound(self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);};
void() hunter_idle2 =[ $idle2, hunter_idle3 ] {ai_stand();};
void() hunter_idle3 =[ $idle3, hunter_idle1 ] {ai_stand();};

// Walk
void() hunter_walk1 =[ $walk1, hunter_walk2 ] {ai_walk(3); if (random() < 0.2) sound(self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);};
void() hunter_walk2 =[ $walk2, hunter_walk3 ] {ai_walk(4);};
void() hunter_walk3 =[ $walk3, hunter_walk4 ] {ai_walk(5);};
void() hunter_walk4 =[ $walk4, hunter_walk5 ] {ai_walk(6);};
void() hunter_walk5 =[ $walk5, hunter_walk1 ] {ai_walk(5); sound(self, CHAN_VOICE, "soldier/step1.wav", 1, ATTN_NORM);};

// Run with custom attack check and cooldown
void() hunter_run1 =[ $run1, hunter_run2 ] {
    ai_run(8); if (random() < 0.2) sound(self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
    if (self.enemy && visible(self.enemy) && vlen(self.origin - self.enemy.origin) <= 1000 && (time - last_attack) >= 2.0) self.think = hunter_fire1;
};
void() hunter_run2 =[ $run2, hunter_run3 ] {ai_run(9);};
void() hunter_run3 =[ $run3, hunter_run4 ] {ai_run(10);};
void() hunter_run4 =[ $run4, hunter_run5 ] {ai_run(11);};
void() hunter_run5 =[ $run5, hunter_run1 ] {ai_run(10); sound(self, CHAN_VOICE, "soldier/step1.wav", 1, ATTN_NORM);};

// Fire with movement after shot
void() hunter_fire1 =[ $fire1, hunter_fire2 ] {ai_face();};
void() hunter_fire2 =[ $fire2, hunter_fire3 ] {ai_face(); hunter_shoot();};
void() hunter_fire3 =[ $fire3, hunter_run1 ] {ai_face(); if (random() < 0.3) self.think = hunter_fire2; else self.think = hunter_run1;};

// Death
vector() explosion_origin =
{
    local vector org;
    org_x = self.absmin_x + (random() * self.size_x);
    org_y = self.absmin_y + (random() * self.size_y);
    org_z = self.absmin_z + (random() * self.size_z);
    return org;
};

void() hunter_explode =
{
    local entity new;
    sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
    new = spawn();
    new.origin = explosion_origin();
    setsize(new, '0 0 0', '0 0 0');
    new.movetype = MOVETYPE_NONE;
    new.solid = SOLID_NOT;
    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_EXPLOSION);
    WriteCoord(MSG_BROADCAST, new.origin_x);
    WriteCoord(MSG_BROADCAST, new.origin_y);
    WriteCoord(MSG_BROADCAST, new.origin_z);
    new.think = SUB_Remove;
    new.nextthink = time + 0.1;
    ThrowGib("progs/h_guard.mdl", self.health * 2);
    ThrowGib("progs/gib1.mdl", self.health * 0.7);
    ThrowGib("progs/gib2.mdl", self.health * 1.2);
    ThrowGib("progs/gib3.mdl", self.health * 1.7);
    T_RadiusDamage(self, self, 100, world);
    remove(self);
};

void() hunter_die1 =[ $die1, hunter_die2 ] {};
void() hunter_die2 =[ $die2, hunter_die3 ] {};
void() hunter_die3 =[ $die3, hunter_die3 ] {hunter_explode();};

void() hunter_death =
{
    if (self.health < -80)
    {
        hunter_explode();
        return;
    }
    sound(self, CHAN_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
    hunter_die1();
};

/*QUAKED monster_hunter (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_hunter =
{
    if (deathmatch)
    {
        remove(self);
        return;
    }
    precache_model("progs/hunter.mdl");
    precache_model("progs/h_guard.mdl");
    precache_model("progs/gib1.mdl");
    precache_model("progs/gib2.mdl");
    precache_model("progs/gib3.mdl");
    precache_model("progs/missile.mdl");
    precache_sound("soldier/death1.wav");
    precache_sound("soldier/idle.wav");
    precache_sound("soldier/step1.wav");
    precache_sound("weapons/rocket1i.wav");
    precache_sound("weapons/r_exp3.wav");
    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_STEP;
    setmodel(self, "progs/hunter.mdl");
    setsize(self, '-16 -16 -24', '16 16 40');
    self.health = 600;
    sound(self, CHAN_VOICE, "soldier/sight1.wav", 1, ATTN_NORM);
    self.th_stand = hunter_idle1;
    self.th_walk = hunter_walk1;
    self.th_run = hunter_run1;
    self.th_die = hunter_death;
    walkmonster_start();
};