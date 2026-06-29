// trigger_soundtrack.qc
// Muda a musica quando o jogador entra no trigger
//
// Uso no mapa:
//   - Crie uma entidade trigger_soundtrack
//   - Defina o campo "tracknum" com o numero da track desejada (ex: 2)
//   - O brush vira o gatilho, basta o jogador entrar nele
//
// No Quakespasm, coloque as musicas em id1/music/ com o nome:
//   track02.mp3, track03.mp3, etc.

void() music_touch =
{
	local entity pl;

	if (other.classname != "player")
		return;

	self.touch = SUB_Null;

	// Quakespasm usa stuffcmd com comando "music"
	pl = find(world, classname, "player");
	while (pl != world)
	{
		stuffcmd(pl, "music track0");
		stuffcmd(pl, ftos(self.tracknum));
		stuffcmd(pl, "\n");
		pl = find(pl, classname, "player");
	}

	self.think = trigger_reactivate;
	self.nextthink = time + 2;
};

void() trigger_soundtrack =
{
	if (!self.tracknum)
		self.tracknum = 1;

	InitTrigger();
	self.touch = music_touch;
};
