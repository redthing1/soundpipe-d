import soundpipe;
import core.stdc.stdlib;
import core.stdc.stdio;
import core.stdc.math;
import core.stdc.time;

enum NVOICES = 5;

struct oscil {
	sp_osc* osc;
	sp_randi* rnd;
}

struct UserData {
	//sp_osc *osc;
	//sp_randi *rnd;
	oscil[NVOICES] v;
	sp_ftbl* ft;
	sp_revsc* rev;
	sp_dcblock* dcblk;
}

float midi2cps(int nn) {
	return pow(2, (nn - 69.0) / 12.0) * 440.0;
}

extern(C) void write_osc(sp_data* data, void* ud) {
	UserData* udp = cast(UserData*) ud;
	int i;
	float amp = 0;
	float osc = 0;
	float dry = 0;
	float wet = 0;
	float blk = 0;
	float foo = 0;
	for (i = 0; i < NVOICES; i++) {
		sp_randi_compute(data, udp.v[i].rnd, null, &amp);
		sp_osc_compute(data, udp.v[i].osc, null, &osc);
		dry += osc * amp;
	}
	sp_revsc_compute(data, udp.rev, &dry, &dry, &wet, &foo);

	sp_dcblock_compute(data, udp.dcblk, &wet, &blk);
	data.out_[0] = 0.5 * dry + 0.3 * wet;
}

int main() {
	srand(cast(uint) time(null));
	UserData ud;
	sp_data* sp;
	sp_create(&sp);

	int[] notes = [60, 67, 71, 74, 76];
	int i;

	sp_dcblock_create(&ud.dcblk);
	sp_revsc_create(&ud.rev);
	sp_ftbl_create(sp, &ud.ft, 2048);

	sp_gen_file(sp, ud.ft, "FMSine111.wav");
	for (i = 0; i < NVOICES; i++) {
		sp_osc_create(&ud.v[i].osc);
		sp_randi_create(&ud.v[i].rnd);
		sp_osc_init(sp, ud.v[i].osc, ud.ft, 0);
		ud.v[i].osc.amp = 0.3;
		ud.v[i].osc.freq = midi2cps(notes[i]);
		sp_randi_init(sp, ud.v[i].rnd);
		ud.v[i].rnd.cps = 0.8;
	}

	sp_revsc_init(sp, ud.rev);
	sp_dcblock_init(sp, ud.dcblk);
	sp.len = 44_100 * 40;

	sp_process(sp, &ud, &write_osc);

	sp_revsc_destroy(&ud.rev);
	sp_dcblock_destroy(&ud.dcblk);
	sp_ftbl_destroy(&ud.ft);
	for (i = 0; i < NVOICES; i++) {
		sp_osc_destroy(&ud.v[i].osc);
		sp_randi_destroy(&ud.v[i].rnd);
	}
	sp_destroy(&sp);
	return 0;
}
