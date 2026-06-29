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

BLOB / TARBABY

Modo extra:
- Spawnflag 16 = KAMIKAZE
  * corre normalmente
  * ao se aproximar do player (<= 130 units), dispara uma bomba curta
    distância tipo WrathMissile em direção ao player
  * em seguida o tarbaby some
  * sem mitose

==============================================================================
*/

$cd /raid/quake/id1/models/tarbaby
$origin 0 0 24
$base base              

//$skin skin
$skin base
$skin skin2
$skin skin

$frame walk1 walk2 walk3 walk4  walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16 walk17 walk18 walk19
$frame walk20 walk21 walk22 walk23 walk24 walk25

$frame run1 run2 run3 run4 run5 run6  run7 run8 run9 run10 run11 run12 run13
$frame run14 run15 run16 run17 run18 run19 run20 run21 run22 run23
$frame run24 run25

$frame jump1 jump2 jump3 jump4 jump5 jump6

$frame fly1 fly2 fly3 fly4

$frame exp

// Protótipos
void() tbaby_die1;
void() tbaby_kamikaze_check;
void() tbaby_bomb_think;
void() tbaby_bomb_touch;
void() tbaby_kamikaze_attack;

/* ---------- CHECAGEM KAMIKAZE: DISPARAR BOMBA A 130 UNITS ---------- */

void() tbaby_kamikaze_check =
{
    local entity targ, best;
    local vector v;
    local float dist, bestdist;

    if (!(self.spawnflags & 16))
        return; // não é kamikaze, ignora

    // Se já disparou (marca usando self.enemy == world, por ex), não faz de novo
    // (opcional, mas evita múltiplos disparos num frame bugado)
    if (self.health <= 0)
        return;

    // Garante um enemy válido: player vivo mais próximo
    if (!self.enemy || self.enemy.health <= 0)
    {
        best = world;
        bestdist = 999999;

        targ = find(world, classname, "player");
        while (targ)
        {
            if (targ.health > 0)
            {
                v = self.origin - targ.origin;
                dist = vlen(v);
                if (dist < bestdist)
                {
                    bestdist = dist;
                    best = targ;
                }
            }
            targ = find(targ, classname, "player");
        }

        if (best == world)
            return;

        self.enemy = best;
    }

    v = self.origin - self.enemy.origin;
    dist = vlen(v);

    // Quando chegar a 130 units, dispara bomba kamikaze
    if (dist <= 130)
    {
        tbaby_kamikaze_attack();
    }
};

/* ---------- PROJÉTIL-BOMBA ESTILO WRATH ---------- */

void() tbaby_bomb_think =
{
    // failsafe: se o owner morreu ou algo bugou, só remove
    if (!self.owner)
    {
        remove(self);
        return;
    }

    // pode adicionar efeitos contínuos aqui (trail, etc.), se quiser

    self.nextthink = time + 0.1;
    self.think = tbaby_bomb_think;
};

void() tbaby_bomb_touch =
{
    // não explode no próprio dono (caso colisão imediata)
    if (other == self.owner)
    {
        remove(self);
        return;
    }

    // Explosão curta distância
    T_RadiusDamage(self, self.owner, 40, world); // dano 40, ajusta se quiser
    sound(self, CHAN_WEAPON, "blob/death1.wav", 1, ATTN_NORM);

    WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte(MSG_BROADCAST, TE_TAREXPLOSION);
    WriteCoord(MSG_BROADCAST, self.origin_x);
    WriteCoord(MSG_BROADCAST, self.origin_y);
    WriteCoord(MSG_BROADCAST, self.origin_z);

    // Converte em sprite de explosão, igual estilo WrathMissile
    self.velocity = '0 0 0';
    self.touch = SUB_Null;
    setmodel(self, "progs/s_explod.spr");
    self.solid = SOLID_NOT;
    s_explode1();
};

/*
================
tbaby_kamikaze_attack

Dispara uma bomba em direção ao player (tipo WrathMissile, mas curtinho)
e some em seguida.
================
*/
void() tbaby_kamikaze_attack =
{
    local entity bomb;
    local vector dir, org;

    if (!self.enemy || self.enemy.health <= 0)
        return;

    // Direção da bomba (mirando centro do player)
    dir = normalize((self.enemy.origin + '0 0 10') - self.origin);

    // Origem da bomba, um pouco à frente e pra cima do tarbaby
    org = self.origin + dir * 20 + '0 0 16';

    // Cria o projétil-bomba
    bomb = spawn();
    bomb.owner = self;
    bomb.solid = SOLID_BBOX;
    bomb.movetype = MOVETYPE_FLYMISSILE;

    // Pode usar uma bolinha ou o próprio modelo do tarbaby;
    // aqui uso a sprite de explosão como modelo inicial pequeno
    setmodel(bomb, "progs/w_ball.mdl"); // se não tiver, troca pra outro mdl/sprite

    setsize(bomb, '0 0 0', '0 0 0');
    setorigin(bomb, org);

    bomb.velocity = dir * 300;     // velocidade moderada
    bomb.avelocity = '300 300 300';
    bomb.enemy = self.enemy;
    bomb.touch = tbaby_bomb_touch;
    bomb.nextthink = time + 0.1;
    bomb.think = tbaby_bomb_think;

    // marca tempo de recarga do ataque, se quiser
    self.attack_finished = time + 2;

    // Depois de disparar, o tarbaby some (não explode, só desaparece)
    remove(self);
};

/* ---------- ORIGINAL: STAND / WALK / RUN / JUMP / MITOSE / ETC ---------- */

void()  tbaby_stand1    =[      $walk1,         tbaby_stand1    ] {ai_stand();};

void()  tbaby_hang1             =[      $walk1,         tbaby_hang1     ] {ai_stand();};

void()  tbaby_walk1     =[      $walk1,         tbaby_walk2     ] {ai_turn();};
void()  tbaby_walk2     =[      $walk2,         tbaby_walk3     ] {ai_turn();};
void()  tbaby_walk3     =[      $walk3,         tbaby_walk4     ] {ai_turn();};
void()  tbaby_walk4     =[      $walk4,         tbaby_walk5     ] {ai_turn();};
void()  tbaby_walk5     =[      $walk5,         tbaby_walk6     ] {ai_turn();};
void()  tbaby_walk6     =[      $walk6,         tbaby_walk7     ] {ai_turn();};
void()  tbaby_walk7     =[      $walk7,         tbaby_walk8     ] {ai_turn();};
void()  tbaby_walk8     =[      $walk8,         tbaby_walk9     ] {ai_turn();};
void()  tbaby_walk9     =[      $walk9,         tbaby_walk10    ] {ai_turn();};
void()  tbaby_walk10    =[      $walk10,                tbaby_walk11    ] {ai_turn();};
void()  tbaby_walk11    =[      $walk11,                tbaby_walk12    ] {ai_walk(2);};
void()  tbaby_walk12    =[      $walk12,                tbaby_walk13    ] {ai_walk(2);};
void()  tbaby_walk13    =[      $walk13,                tbaby_walk14    ] {ai_walk(2);};
void()  tbaby_walk14    =[      $walk14,                tbaby_walk15    ] {ai_walk(2);};
void()  tbaby_walk15    =[      $walk15,                tbaby_walk16    ] {ai_walk(2);};
void()  tbaby_walk16    =[      $walk16,                tbaby_walk17    ] {ai_walk(2);};
void()  tbaby_walk17    =[      $walk17,                tbaby_walk18    ] {ai_walk(2);};
void()  tbaby_walk18    =[      $walk18,                tbaby_walk19    ] {ai_walk(2);};
void()  tbaby_walk19    =[      $walk19,                tbaby_walk20    ] {ai_walk(2);};
void()  tbaby_walk20    =[      $walk20,                tbaby_walk21    ] {ai_walk(2);};
void()  tbaby_walk21    =[      $walk21,                tbaby_walk22    ] {ai_walk(2);};
void()  tbaby_walk22    =[      $walk22,                tbaby_walk23    ] {ai_walk(2);};
void()  tbaby_walk23    =[      $walk23,                tbaby_walk24    ] {ai_walk(2);};
void()  tbaby_walk24    =[      $walk24,                tbaby_walk25    ] {ai_walk(2);};
void()  tbaby_walk25    =[      $walk25,                tbaby_walk1     ] {ai_walk(2);};

void()  tbaby_run1      =[      $run1,          tbaby_run2      ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_run2      =[      $run2,          tbaby_run3      ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_run3      =[      $run3,          tbaby_run4      ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_run4      =[      $run4,          tbaby_run5      ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_run5      =[      $run5,          tbaby_run6      ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_run6      =[      $run6,          tbaby_run7      ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_run7      =[      $run7,          tbaby_run8      ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_run8      =[      $run8,          tbaby_run9      ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_run9      =[      $run9,          tbaby_run10     ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_run10     =[      $run10,         tbaby_run11     ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_run11     =[      $run11,         tbaby_run12     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run12     =[      $run12,         tbaby_run13     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run13     =[      $run13,         tbaby_run14     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run14     =[      $run14,         tbaby_run15     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run15     =[      $run15,         tbaby_run16     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run16     =[      $run16,         tbaby_run17     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run17     =[      $run17,         tbaby_run18     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run18     =[      $run18,         tbaby_run19     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run19     =[      $run19,         tbaby_run20     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run20     =[      $run20,         tbaby_run21     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run21     =[      $run21,         tbaby_run22     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run22     =[      $run22,         tbaby_run23     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run23     =[      $run23,         tbaby_run24     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run24     =[      $run24,         tbaby_run25     ] {ai_run(2); tbaby_kamikaze_check();};
void()  tbaby_run25     =[      $run25,         tbaby_run1      ] {ai_run(2); tbaby_kamikaze_check();};


//============================================================================


void()  tbaby_jump1;

void()  Tar_JumpTouch =
{
    local   float   ldmg;

    if (other.takedamage && other.classname != self.classname)
    {
        if ( vlen(self.velocity) > 400 )
        {
            ldmg = 10 + 10*random();
            T_Damage (other, self, self, ldmg);     
            sound (self, CHAN_WEAPON, "blob/hit1.wav", 1, ATTN_NORM);
        }
    }
    else
        sound (self, CHAN_WEAPON, "blob/land1.wav", 1, ATTN_NORM);


    if (!checkbottom(self))
    {
        if (self.flags & FL_ONGROUND)
        {       // jump randomly to not get hung up
//dprint ("popjump\n");
            self.touch = SUB_Null;
            self.think = tbaby_run1;
            self.movetype = MOVETYPE_STEP;
            self.nextthink = time + 0.1;
        }
        return; // not on ground yet
    }

    self.touch = SUB_Null;
    self.think = tbaby_jump1;
    self.nextthink = time + 0.1;
};

void()  tbaby_jump5;

void()  tbaby_fly1              =[      $fly1,  tbaby_fly2      ] { tbaby_kamikaze_check(); };
void()  tbaby_fly2              =[      $fly2,  tbaby_fly3      ] { tbaby_kamikaze_check(); };
void()  tbaby_fly3              =[      $fly3,  tbaby_fly4      ] { tbaby_kamikaze_check(); };
void()  tbaby_fly4              =[      $fly4,  tbaby_fly1      ] {
    self.cnt = self.cnt + 1;
    if (self.cnt == 4)
    {
//dprint ("spawn hop\n");
        tbaby_jump5 ();
    }
    tbaby_kamikaze_check();
};

void()  tbaby_jump1             =[      $jump1, tbaby_jump2             ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_jump2             =[      $jump2, tbaby_jump3             ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_jump3             =[      $jump3, tbaby_jump4             ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_jump4             =[      $jump4, tbaby_jump5             ] {ai_face(); tbaby_kamikaze_check();};
void()  tbaby_jump5             =[      $jump5, tbaby_jump6             ]
{       
    self.movetype = MOVETYPE_BOUNCE;
    self.touch = Tar_JumpTouch;
    makevectors (self.angles);
    self.origin_z = self.origin_z + 1;
    self.velocity = v_forward * 600 + '0 0 200';
    self.velocity_z = self.velocity_z + random()*150;
    if (self.flags & FL_ONGROUND)
        self.flags = self.flags - FL_ONGROUND;
    self.cnt = 0;
    tbaby_kamikaze_check();
};
void()  tbaby_jump6     =[      $jump6,tbaby_fly1       ] { tbaby_kamikaze_check(); };



//=============================================================================

void()  tbaby_die2;

void()  tbaby_die1      =[      $exp,           tbaby_die2      ] {
    self.takedamage = DAMAGE_NO;
};
void()  tbaby_die2      =[      $exp,           tbaby_run1      ] 
{
    T_RadiusDamage (self, self, 120, world);

    sound (self, CHAN_VOICE, "blob/death1.wav", 1, ATTN_NORM);
    self.origin = self.origin - 8*normalize(self.velocity);

    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
    WriteCoord (MSG_BROADCAST, self.origin_x);
    WriteCoord (MSG_BROADCAST, self.origin_y);
    WriteCoord (MSG_BROADCAST, self.origin_z);
    
    BecomeExplosion ();
};

//=============================================================================
void() tbaby_mitosis;

void() tbaby_checknew =
{
    if (!walkmove(0,0))
    {
        remove(self);
        return;
    }
    
    self.enemy = self.enemy;
    self.th_stand = tbaby_stand1;
    self.th_walk = tbaby_walk1;
    self.th_run = tbaby_run1;
    self.th_missile = tbaby_jump1;
    self.th_melee = tbaby_jump1;
    self.th_die = tbaby_die1;       
    self.origin_z = self.origin_z + 1;      // raise off floor a bit
    droptofloor();

    if (!walkmove(0,0))
    {
        self.owner.th_pain = tbaby_mitosis;
        remove(self);
        return;
    }

    self.takedamage = DAMAGE_AIM;
    self.ideal_yaw = self.angles * '0 1 0';
    if (!self.yaw_speed)
        self.yaw_speed = 20;
    self.view_ofs = '0 0 25';
    self.use = monster_use;
    self.flags = self.flags | FL_MONSTER;
    self.pausetime = 99999999;
    self.th_stand ();
    self.nextthink = self.nextthink + random()*0.5;

    total_monsters = total_monsters + 1;
  
    WriteByte (MSG_BROADCAST, SVC_UPDATESTAT);
    WriteByte (MSG_BROADCAST, STAT_TOTALMONSTERS);
    WriteLong (MSG_BROADCAST, total_monsters);
};

void() tbaby_mitosis =
{
    local entity    newSpawn;
    
    if ( random() < 0.35 )
    {
        newSpawn = spawn();
        newSpawn.classname = self.classname;
        newSpawn.movetype = MOVETYPE_STEP;
        setsize (newSpawn, '-16 -16 -24', '16 16 40');
        newSpawn.health = 80;
        if (self.skin == 1)
            newSpawn.health = 60;
        else if (self.skin == 2)
            newSpawn.health = 100;

        newSpawn.owner = self;
        self.th_pain = SUB_Null;
        
        setmodel (newSpawn, "progs/tarbaby.mdl");
        newSpawn.solid = SOLID_SLIDEBOX;
        newSpawn.skin = self.skin;
        
        setorigin (newSpawn, self.origin);              
        newSpawn.think = tbaby_checknew;
        newSpawn.nextthink = time + 0.5;

        sound (newSpawn, CHAN_VOICE, "blob/mytosis.wav", 1, ATTN_NORM);
    }
};

/*QUAKED monster_tarbaby (1 0 0) (-16 -16 -24) (16 16 24) Ambush Blue Green Spots KAMIKAZE
The Spawn (and hellspawn)

The spawn type is random by default.
If you want a specific type, select "Blue", "Green", or "Spots".

KAMIKAZE (16):
  - Corre normalmente
  - Ao chegar a 130 units de um player, dispara uma bomba curta distância
    estilo WrathMissile em direção ao player e some
  - Sem mitose
*/
void() monster_tarbaby =
{
    local float     myRand;
    local float     skillLevel;

    if (deathmatch)
    {
        remove(self);
        return;
    }
    precache_model2 ("progs/tarbaby.mdl");

    precache_sound2 ("blob/death1.wav");
    precache_sound2 ("blob/hit1.wav");
    precache_sound2 ("blob/land1.wav");
    precache_sound2 ("blob/sight1.wav");
    precache_sound2 ("blob/mytosis.wav");

    // modelo da bombinha (igual WrathBall)
    precache_model("progs/w_ball.mdl");
    precache_model("progs/s_explod.spr");

    self.solid = SOLID_SLIDEBOX;
    self.movetype = MOVETYPE_STEP;

    setmodel (self, "progs/tarbaby.mdl");

    setsize (self, '-16 -16 -24', '16 16 40');
    self.health = 80;

    self.th_stand = tbaby_stand1;
    self.th_walk = tbaby_walk1;
    self.th_run = tbaby_run1;
    self.th_missile = tbaby_jump1;
    self.th_melee = tbaby_jump1;
    self.th_die = tbaby_die1;

    // === KAMIKAZE TEM PRIORIDADE SOBRE OS OUTROS MODOS ===
    if (self.spawnflags & 16)
    {
        // modo kamikaze: skin 2, mais frágil, sem mitose
        self.skin = 2;
        self.health = 50;
        self.th_pain = SUB_Null;
    }
    else if (self.spawnflags & 8)
    {
        self.th_pain = tbaby_mitosis;
        self.skin = 2;
        self.health = 100;
    }
    else if (self.spawnflags & 4)
    {
        self.th_pain = tbaby_mitosis;
        self.skin = 1;
        self.health = 60;
    }
    else if (self.spawnflags & 2)
    {
        self.skin = 0;
    }
    else
    {
        skillLevel = cvar ( "skill" );
        myRand = skillLevel * 0.2;
        myRand = myRand + random();
    
        if (myRand > 0.8 && skillLevel > 1)
        {
            self.th_pain = tbaby_mitosis;
            self.skin = 2;
            self.health = 100;
        }
        else if (myRand > 0.5)
        {
            self.th_pain = tbaby_mitosis;
            self.skin = 1;
            self.health = 60;
        }
        else
        {
            self.skin = 0;
        }
    }

    walkmonster_start ();
};
