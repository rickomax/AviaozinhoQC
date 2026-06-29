/*
=============================================================================
monster_dreadnaught
code by john fitzgibbons, adapted to shoot fireballs, simplified for standard QuakeC
==============================================================================
*/
$cd id1/models/enforcer
$origin 0 -6 24
$base base
$skin skin
$frame dread_stand1 dread_stand2 dread_stand3 dread_stand4 dread_stand5 dread_stand6 dread_stand7
$frame dread_walk1 dread_walk2 dread_walk3 dread_walk4 dread_walk5 dread_walk6 dread_walk7 dread_walk8 dread_walk9 dread_walk10
$frame dread_walk11 dread_walk12 dread_walk13 dread_walk14 dread_walk15 dread_walk16
$frame dread_run1 dread_run2 dread_run3 dread_run4 dread_run5 dread_run6 dread_run7 dread_run8
$frame dread_attack1 dread_attack2 dread_attack3 dread_attack4 dread_attack5 dread_attack6
$frame dread_attack7 dread_attack8 dread_attack9 dread_attack10
$frame dread_death1 dread_death2 dread_death3 dread_death4 dread_death5 dread_death6 dread_death7 dread_death8
$frame dread_death9 dread_death10 dread_death11 dread_death12 dread_death13 dread_death14
$frame dread_fdeath1 dread_fdeath2 dread_fdeath3 dread_fdeath4 dread_fdeath5 dread_fdeath6 dread_fdeath7 dread_fdeath8
$frame dread_fdeath9 dread_fdeath10 dread_fdeath11
$frame dread_paina1 dread_paina2 dread_paina3 dread_paina4
$frame dread_painb1 dread_painb2 dread_painb3 dread_painb4 dread_painb5
$frame dread_painc1 dread_painc2 dread_painc3 dread_painc4 dread_painc5 dread_painc6 dread_painc7 dread_painc8
$frame dread_paind1 dread_paind2 dread_paind3 dread_paind4 dread_paind5 dread_paind6 dread_paind7 dread_paind8
$frame dread_paind9 dread_paind10 dread_paind11 dread_paind12 dread_paind13 dread_paind14 dread_paind15 dread_paind16
$frame dread_paind17 dread_paind18 dread_paind19

//============================================================================
void() dread_flame_touch =
{
    if (other == self.owner)
        return;
    if (other.solid == SOLID_TRIGGER)
        return; // trigger field, do nothing
    self.movedir = '0 0 0';
    if (self.dmg > 0 && other.health > 0)
    {
        T_Damage(other, self, self.owner, self.dmg);
        self.dmg = 0;
    }
    remove(self);
};

void() dread_flame_fly =
{
    self.frame = self.frame + 1;
    if (self.frame > 7 || pointcontents(self.origin) != CONTENT_EMPTY)
    {
        remove(self);
        return;
    }
    self.velocity = self.velocity + '0 0 30' - (self.movedir * 0.12);
    self.nextthink = time + 0.1;
};

void(vector org, vector vec) dread_make_flame =
{
    local vector variance;
    local float roll;
    local entity flame;
    flame = spawn();
    flame.owner = self;
    setmodel(flame, "progs/s_flame.spr");
    setorigin(flame, org);
    flame.movetype = MOVETYPE_FLY;
    flame.solid = SOLID_BBOX;
    variance = '-10 -10 -10' + random() * '20 20 20';
    flame.movedir = normalize(vec) * 250 + '0 0 -50' + variance;
    flame.velocity = flame.movedir;
    roll = 350 + random() * 20;
    flame.angles_z = anglemod(roll);
    flame.nextthink = time + 0.1;
    flame.think = dread_flame_fly;
    flame.touch = dread_flame_touch;
    flame.classname = "dread_flame";
    flame.dmg = 5;
    flame.frame = 0;
    setsize(flame, '0 0 0', '0 0 0');
};

void() dread_fire =
{
    local vector org;
    makevectors(self.angles);
    org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';
    dread_make_flame(org, self.enemy.origin - self.origin);
};

void() dread_atk1 =[ $dread_attack1, dread_atk2 ] {ai_face();};
void() dread_atk2 =[ $dread_attack3, dread_atk3 ] {ai_face();};
void() dread_atk3 =[ $dread_attack5, dread_atk4 ] {
    sound(self, CHAN_WEAPON, "dread/flameon.wav", 1, ATTN_NORM);
    dread_fire();
    ai_face();
    self.attack_finished = time + 0.3;
};
void() dread_atk4 =[ $dread_attack5, dread_atk5 ] {
    dread_fire();
    ai_face();
    if (self.attack_finished > time || (range(self.enemy) == RANGE_MELEE && self.enemy.health > 0))
        self.think = dread_atk4;
};
void() dread_atk5 =[ $dread_attack10, dread_run1 ] {
    sound(self, CHAN_WEAPON, "dread/flameoff.wav", 1, ATTN_NORM);
    ai_face();
    SUB_CheckRefire(dread_atk1);
};

//============================================================================
void() dread_stand1 =[ $dread_stand1, dread_stand2 ] {ai_stand();};
void() dread_stand2 =[ $dread_stand2, dread_stand3 ] {ai_stand();};
void() dread_stand3 =[ $dread_stand3, dread_stand4 ] {ai_stand();};
void() dread_stand4 =[ $dread_stand4, dread_stand5 ] {ai_stand();};
void() dread_stand5 =[ $dread_stand5, dread_stand6 ] {ai_stand();};
void() dread_stand6 =[ $dread_stand6, dread_stand7 ] {ai_stand();};
void() dread_stand7 =[ $dread_stand7, dread_stand1 ] {ai_stand();};

void() dread_walk1 =[ $dread_walk1, dread_walk2 ] {
    if (random() < 0.2)
        sound(self, CHAN_VOICE, "dread/idle1.wav", 1, ATTN_IDLE);
    ai_walk(2);
};
void() dread_walk2 =[ $dread_walk2, dread_walk3 ] {ai_walk(4);};
void() dread_walk3 =[ $dread_walk3, dread_walk4 ] {ai_walk(4);};
void() dread_walk4 =[ $dread_walk4, dread_walk5 ] {ai_walk(3);};
void() dread_walk5 =[ $dread_walk5, dread_walk6 ] {ai_walk(1);};
void() dread_walk6 =[ $dread_walk6, dread_walk7 ] {ai_walk(2);};
void() dread_walk7 =[ $dread_walk7, dread_walk8 ] {ai_walk(2);};
void() dread_walk8 =[ $dread_walk8, dread_walk9 ] {ai_walk(1);};
void() dread_walk9 =[ $dread_walk9, dread_walk10 ] {ai_walk(2);};
void() dread_walk10 =[ $dread_walk10, dread_walk11 ] {ai_walk(4);};
void() dread_walk11 =[ $dread_walk11, dread_walk12 ] {ai_walk(4);};
void() dread_walk12 =[ $dread_walk12, dread_walk13 ] {ai_walk(1);};
void() dread_walk13 =[ $dread_walk13, dread_walk14 ] {ai_walk(2);};
void() dread_walk14 =[ $dread_walk14, dread_walk15 ] {ai_walk(3);};
void() dread_walk15 =[ $dread_walk15, dread_walk16 ] {ai_walk(4);};
void() dread_walk16 =[ $dread_walk16, dread_walk1 ] {ai_walk(2);};

float DREAD_RUN_SPEED = 1.5;
void() dread_run1 =[ $dread_run1, dread_run2 ] {ai_run(18 * DREAD_RUN_SPEED);
    if (random() < 0.1)
        sound(self, CHAN_VOICE, "dread/idle1.wav", 1, ATTN_IDLE);
};
void() dread_run2 =[ $dread_run2, dread_run3 ] {ai_run(14 * DREAD_RUN_SPEED);};
void() dread_run3 =[ $dread_run3, dread_run4 ] {ai_run(7 * DREAD_RUN_SPEED);};
void() dread_run4 =[ $dread_run4, dread_run5 ] {ai_run(12 * DREAD_RUN_SPEED);};
void() dread_run5 =[ $dread_run5, dread_run6 ] {ai_run(14 * DREAD_RUN_SPEED);};
void() dread_run6 =[ $dread_run6, dread_run7 ] {ai_run(14 * DREAD_RUN_SPEED);};
void() dread_run7 =[ $dread_run7, dread_run8 ] {ai_run(7 * DREAD_RUN_SPEED);};
void() dread_run8 =[ $dread_run8, dread_run1 ] {ai_run(11 * DREAD_RUN_SPEED);};

void() dread_paina1 =[ $dread_paina1, dread_paina2 ] {};
void() dread_paina2 =[ $dread_paina2, dread_paina3 ] {};
void() dread_paina3 =[ $dread_paina3, dread_paina4 ] {};
void() dread_paina4 =[ $dread_paina4, dread_run1 ] {};
void() dread_painb1 =[ $dread_painb1, dread_painb2 ] {};
void() dread_painb2 =[ $dread_painb2, dread_painb3 ] {};
void() dread_painb3 =[ $dread_painb3, dread_painb4 ] {};
void() dread_painb4 =[ $dread_painb4, dread_painb5 ] {};
void() dread_painb5 =[ $dread_painb5, dread_run1 ] {};
void() dread_painc1 =[ $dread_painc1, dread_painc2 ] {};
void() dread_painc2 =[ $dread_painc2, dread_painc3 ] {};
void() dread_painc3 =[ $dread_painc3, dread_painc4 ] {};
void() dread_painc4 =[ $dread_painc4, dread_painc5 ] {};
void() dread_painc5 =[ $dread_painc5, dread_painc6 ] {};
void() dread_painc6 =[ $dread_painc6, dread_painc7 ] {};
void() dread_painc7 =[ $dread_painc7, dread_painc8 ] {};
void() dread_painc8 =[ $dread_painc8, dread_run1 ] {};

void(entity attacker, float damage) dread_pain =
{
    local float r;
    if (self.health < self.max_health * 0.1) self.skin = 3;
    else if (self.health < self.max_health * 0.5 && self.health >= self.max_health * 0.25) self.skin = 2;
    else if (self.health < self.max_health * 0.75 && self.health >= self.max_health * 0.5) self.skin = 1;
    r = random();
    if (self.pain_finished > time)
        return; // too soon
    if (random() * 150 > damage)
        return; // didn't flinch
    if (r < 0.5)
        sound(self, CHAN_VOICE, "dread/dread_pain1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "dread/dread_pain2.wav", 1, ATTN_NORM);
    if (r < 0.33)
    {
        self.pain_finished = time + 2;
        dread_paina1();
    }
    else if (r < 0.66)
    {
        self.pain_finished = time + 2;
        dread_painb1();
    }
    else
    {
        self.pain_finished = time + 2;
        dread_painc1();
    }
    if (self.attack_finished > time) // turn off flame sound
    {
        sound(self, CHAN_WEAPON, "dread/flameoff.wav", 1, ATTN_NORM);
    }
    else // play sound anyway to be sure the channel is silent
    {
        sound(self, CHAN_WEAPON, "misc/null.wav", 0, ATTN_NORM);
    }
};

//============================================================================
void() dread_die1 =[ $dread_death1, dread_die2 ] {};
void() dread_die2 =[ $dread_death2, dread_die3 ] {};
void() dread_die3 =[ $dread_death3, dread_die4 ] {self.solid = SOLID_NOT;};
void() dread_die4 =[ $dread_death4, dread_die5 ] {ai_forward(14);};
void() dread_die5 =[ $dread_death5, dread_die6 ] {ai_forward(2);};
void() dread_die6 =[ $dread_death6, dread_die7 ] {};
void() dread_die7 =[ $dread_death7, dread_die8 ] {};
void() dread_die8 =[ $dread_death8, dread_die9 ] {};
void() dread_die9 =[ $dread_death9, dread_die10 ] {ai_forward(3);};
void() dread_die10 =[ $dread_death10, dread_die11 ] {ai_forward(5);};
void() dread_die11 =[ $dread_death11, dread_die12 ] {ai_forward(5);};
void() dread_die12 =[ $dread_death12, dread_die13 ] {ai_forward(5);};
void() dread_die13 =[ $dread_death13, dread_die14 ] {};
void() dread_die14 =[ $dread_death14, dread_die14 ] {remove(self);};
void() dread_fdie1 =[ $dread_fdeath1, dread_fdie2 ] {};
void() dread_fdie2 =[ $dread_fdeath2, dread_fdie3 ] {};
void() dread_fdie3 =[ $dread_fdeath3, dread_fdie4 ] {self.solid = SOLID_NOT;};
void() dread_fdie4 =[ $dread_fdeath4, dread_fdie5 ] {};
void() dread_fdie5 =[ $dread_fdeath5, dread_fdie6 ] {};
void() dread_fdie6 =[ $dread_fdeath6, dread_fdie7 ] {};
void() dread_fdie7 =[ $dread_fdeath7, dread_fdie8 ] {};
void() dread_fdie8 =[ $dread_fdeath8, dread_fdie9 ] {};
void() dread_fdie9 =[ $dread_fdeath9, dread_fdie10 ] {};
void() dread_fdie10 =[ $dread_fdeath10, dread_fdie11 ] {};
void() dread_fdie11 =[ $dread_fdeath11, dread_fdie11 ] {remove(self);};

void() dread_die =
{
    if (self.health < -35) // gib
    {
        self.skin = 0;
        sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
        ThrowHead("progs/h_dread.mdl", self.health);
        ThrowGib("progs/gib1.mdl", self.health);
        ThrowGib("progs/gib1.mdl", self.health);
        ThrowGib("progs/gib2.mdl", self.health);
        ThrowGib("progs/gib3.mdl", self.health);
        ThrowGib("progs/gib3.mdl", self.health);
        remove(self);
    }
    else // regular death
    {
        self.skin = 3;
        sound(self, CHAN_VOICE, "dread/dread_death.wav", 1, ATTN_NORM);
        if (random() > 0.5)
            dread_die1();
        else
            dread_fdie1();
    }
    if (self.attack_finished > time) // turn off flame sound
    {
        sound(self, CHAN_WEAPON, "dread/flameoff.wav", 1, ATTN_NORM);
    }
    else // play sound anyway to be sure the channel is silent
    {
        sound(self, CHAN_WEAPON, "misc/null.wav", 0, ATTN_NORM);
    }
};

// Removed dread_sight function due to th_sight incompatibility

/*QUAKED monster_dreadnaught (1 0 0) (-16 -16 -24) (16 16 40) AMBUSH
Dreadnaught, 150 health points.
AMBUSH: dreadnaught will only wake up on really seeing the player, not another monster getting angry.
*/
void() monster_dreadnaught_start =
{
    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_STEP;
    setmodel(self, "progs/dread.mdl");
    setsize(self, '-16 -16 -24', '16 16 40');
    self.health = 150;
    self.th_stand = dread_stand1;
    self.th_walk = dread_walk1;
    self.th_run = dread_run1;
    self.th_pain = dread_pain;
    self.th_die = dread_die;
    self.th_melee = dread_atk1;
    self.yaw_speed = 40;
    walkmonster_start();
};

void() monster_dreadnaught =
{
    if (deathmatch)
    {
        remove(self);
        return;
    }
    precache_model("progs/dread.mdl");
    precache_model("progs/h_dread.mdl");
    precache_sound("dread/dread_death.wav");
    precache_sound("dread/idle1.wav");
    precache_sound("dread/dread_pain1.wav");
    precache_sound("dread/dread_pain2.wav");
    precache_sound("dread/flameon.wav");
    precache_sound("dread/flameoff.wav");
    precache_sound("misc/null.wav");
    precache_model("progs/s_flame.spr");
    setsize(self, '-16 -16 -24', '16 16 40');
    if (self.spawnflags & 1) // AMBUSH flag
    {
        self.use = monster_dreadnaught_start; // Simplified spawner logic
    }
    else
    {
        monster_dreadnaught_start();
    }
};