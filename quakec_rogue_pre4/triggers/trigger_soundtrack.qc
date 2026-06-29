// trigger_soundtrack.qc
// Muda a musica quando o jogador entra no trigger
//
// Uso no mapa:
//   - Crie uma entidade trigger_soundtrack
//   - Defina o campo "tracknum" com o numero da track desejada (ex: 2)
//   - O brush vira o gatilho, basta o jogador entrar nele
//
// Musicas ficam em id1/music/trackXX.ogg ou trackXX.mp3

void() music_touch =
{
	local entity pl;

	if (other.classname != "player")
		return;

	self.touch = SUB_Null;

	// Envia via protocolo nativo (funciona no engine original)
	WriteByte(MSG_ALL, SVC_CDTRACK);
	WriteByte(MSG_ALL, self.tracknum);
	WriteByte(MSG_ALL, self.tracknum);

	// Fallback via stuffcmd para Quakespasm/FTE
	pl = find(world, classname, "player");
	while (pl != world)
	{
		stuffcmd(pl, "music ");
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
