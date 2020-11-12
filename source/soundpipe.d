import core.stdc.config;
import core.stdc.stdio;

extern (C):

enum SP_BUFSIZE = 4096;

alias SPFLOAT = float;

enum SP_OK = 1;
enum SP_NOT_OK = 0;

enum SP_RANDMAX = 2147483648;

alias sp_frame = c_ulong;

struct sp_auxdata
{
    size_t size;
    void* ptr;
}

struct sp_data
{
    float* out_;
    int sr;
    int nchan;
    c_ulong len;
    c_ulong pos;
    char[200] filename;
    uint rand;
}

struct sp_param
{
    char state;
    float val;
}

int sp_auxdata_alloc (sp_auxdata* aux, size_t size);
int sp_auxdata_free (sp_auxdata* aux);

int sp_create (sp_data** spp);
int sp_createn (sp_data** spp, int nchan);

int sp_destroy (sp_data** spp);
int sp_process (sp_data* sp, void* ud, void function (sp_data*, void*) callback);
int sp_process_raw (sp_data* sp, void* ud, void function (sp_data*, void*) callback);
int sp_process_plot (sp_data* sp, void* ud, void function (sp_data*, void*) callback);
int sp_process_spa (sp_data* sp, void* ud, void function (sp_data*, void*) callback);

float sp_midi2cps (float nn);

int sp_set (sp_param* p, float val);

int sp_out (sp_data* sp, uint chan, float val);

uint sp_rand (sp_data* sp);
void sp_srand (sp_data* sp, uint val);

struct sp_fft
{
    float* utbl;
    short* BRLow;
    short* BRLowCpx;
}

void sp_fft_init (sp_fft* fft, int M);
void sp_fftr (sp_fft* fft, float* buf, int FFTsize);
void sp_fft_cpx (sp_fft* fft, float* buf, int FFTsize);
void sp_ifftr (sp_fft* fft, float* buf, int FFTsize);
void sp_fft_destroy (sp_fft* fft);

alias kiss_fft_scalar = SPFLOAT;

struct kiss_fft_cpx
{
    float r;
    float i;
}

struct kiss_fft_state;
alias kiss_fft_cfg = kiss_fft_state*;
struct kiss_fftr_state;
alias kiss_fftr_cfg = kiss_fftr_state*;

/* SPA: Soundpipe Audio */

enum
{
    read = 0,
    write = 1,
    null_ = 2
}

struct spa_header
{
    char magic;
    char nchan;
    ushort sr;
    uint len;
}

struct sp_audio
{
    spa_header header;
    size_t offset;
    int mode;
    FILE* fp;
    uint pos;
}

enum SP_FT_MAXLEN = 0x1000000L;
enum SP_FT_PHMASK = 0x0FFFFFFL;

struct sp_ftbl
{
    size_t size;
    uint lobits;
    uint lomask;
    float lodiv;
    float sicvt;
    float* tbl;
    char del;
}

int sp_ftbl_create (sp_data* sp, sp_ftbl** ft, size_t size);
int sp_ftbl_init (sp_data* sp, sp_ftbl* ft, size_t size);
int sp_ftbl_bind (sp_data* sp, sp_ftbl** ft, float* tbl, size_t size);
int sp_ftbl_destroy (sp_ftbl** ft);
int sp_gen_vals (sp_data* sp, sp_ftbl* ft, const(char)* string);
int sp_gen_sine (sp_data* sp, sp_ftbl* ft);
int sp_gen_file (sp_data* sp, sp_ftbl* ft, const(char)* filename);
int sp_gen_sinesum (sp_data* sp, sp_ftbl* ft, const(char)* argstring);
int sp_gen_line (sp_data* sp, sp_ftbl* ft, const(char)* argstring);
int sp_gen_xline (sp_data* sp, sp_ftbl* ft, const(char)* argstring);
int sp_gen_gauss (sp_data* sp, sp_ftbl* ft, float scale, uint seed);
int sp_ftbl_loadfile (sp_data* sp, sp_ftbl** ft, const(char)* filename);
int sp_ftbl_loadspa (sp_data* sp, sp_ftbl** ft, const(char)* filename);
int sp_gen_composite (sp_data* sp, sp_ftbl* ft, const(char)* argstring);
int sp_gen_rand (sp_data* sp, sp_ftbl* ft, const(char)* argstring);
int sp_gen_triangle (sp_data* sp, sp_ftbl* ft);

struct sp_tevent
{
    void function (void*) reinit;
    void function (void*, float* out_) compute;
    void* ud;
    int started;
}

int sp_tevent_create (sp_tevent** te);
int sp_tevent_destroy (sp_tevent** te);
int sp_tevent_init (
    sp_data* sp,
    sp_tevent* te,
    void function (void*) reinit,
    void function (void*, float* out_) compute,
    void* ud);
int sp_tevent_compute (sp_data* sp, sp_tevent* te, float* in_, float* out_);

struct sp_adsr
{
    float atk;
    float dec;
    float sus;
    float rel;
    uint timer;
    uint atk_time;
    float a;
    float b;
    float y;
    float x;
    float prev;
    int mode;
}

int sp_adsr_create (sp_adsr** p);
int sp_adsr_destroy (sp_adsr** p);
int sp_adsr_init (sp_data* sp, sp_adsr* p);
int sp_adsr_compute (sp_data* sp, sp_adsr* p, float* in_, float* out_);

struct sp_allpass
{
    float revtime;
    float looptime;
    float coef;
    float prvt;
    sp_auxdata aux;
    uint bufpos;
    uint bufsize;
}

int sp_allpass_create (sp_allpass** p);
int sp_allpass_destroy (sp_allpass** p);
int sp_allpass_init (sp_data* sp, sp_allpass* p, float looptime);
int sp_allpass_compute (sp_data* sp, sp_allpass* p, float* in_, float* out_);

struct sp_atone
{
    float hp;
    float c1;
    float c2;
    float yt1;
    float prvhp;
    float tpidsr;
}

int sp_atone_create (sp_atone** p);
int sp_atone_destroy (sp_atone** p);
int sp_atone_init (sp_data* sp, sp_atone* p);
int sp_atone_compute (sp_data* sp, sp_atone* p, float* in_, float* out_);

struct sp_autowah
{
    void* faust;
    int argpos;
    float*[3] args;
    float* level;
    float* wah;
    float* mix;
}

int sp_autowah_create (sp_autowah** p);
int sp_autowah_destroy (sp_autowah** p);
int sp_autowah_init (sp_data* sp, sp_autowah* p);
int sp_autowah_compute (sp_data* sp, sp_autowah* p, float* in_, float* out_);

struct sp_bal
{
    float asig;
    float csig;
    float ihp;
    float c1;
    float c2;
    float prvq;
    float prvr;
    float prva;
}

int sp_bal_create (sp_bal** p);
int sp_bal_destroy (sp_bal** p);
int sp_bal_init (sp_data* sp, sp_bal* p);
int sp_bal_compute (sp_data* sp, sp_bal* p, float* sig, float* comp, float* out_);

struct sp_bar
{
    float bcL;
    float bcR;
    float iK;
    float ib;
    float scan;
    float T30;
    float pos;
    float vel;
    float wid;

    float* w;
    float* w1;
    float* w2;
    int step;
    int first;
    float s0;
    float s1;
    float s2;
    float t0;
    float t1;
    int i_bcL;
    int i_bcR;
    int N;
    sp_auxdata w_aux;
}

int sp_bar_create (sp_bar** p);
int sp_bar_destroy (sp_bar** p);
int sp_bar_init (sp_data* sp, sp_bar* p, float iK, float ib);
int sp_bar_compute (sp_data* sp, sp_bar* p, float* in_, float* out_);

struct sp_biquad
{
    float b0;
    float b1;
    float b2;
    float a0;
    float a1;
    float a2;
    float reinit;
    float xnm1;
    float xnm2;
    float ynm1;
    float ynm2;
    float cutoff;
    float res;
    float sr;
    float tpidsr;
}

int sp_biquad_create (sp_biquad** p);
int sp_biquad_destroy (sp_biquad** p);
int sp_biquad_init (sp_data* sp, sp_biquad* p);
int sp_biquad_compute (sp_data* sp, sp_biquad* p, float* in_, float* out_);

struct sp_biscale
{
    float min;
    float max;
}

int sp_biscale_create (sp_biscale** p);
int sp_biscale_destroy (sp_biscale** p);
int sp_biscale_init (sp_data* sp, sp_biscale* p);
int sp_biscale_compute (sp_data* sp, sp_biscale* p, float* in_, float* out_);

struct sp_blsaw
{
    void* ud;
    int argpos;
    float*[2] args;
    float* freq;
    float* amp;
}

int sp_blsaw_create (sp_blsaw** p);
int sp_blsaw_destroy (sp_blsaw** p);
int sp_blsaw_init (sp_data* sp, sp_blsaw* p);
int sp_blsaw_compute (sp_data* sp, sp_blsaw* p, float* in_, float* out_);

struct sp_blsquare
{
    void* ud;
    int argpos;
    float*[3] args;
    float* freq;
    float* amp;
    float* width;
}

int sp_blsquare_create (sp_blsquare** p);
int sp_blsquare_destroy (sp_blsquare** p);
int sp_blsquare_init (sp_data* sp, sp_blsquare* p);
int sp_blsquare_compute (sp_data* sp, sp_blsquare* p, float* in_, float* out_);

struct sp_bltriangle
{
    void* ud;
    int argpos;
    float*[2] args;
    float* freq;
    float* amp;
}

int sp_bltriangle_create (sp_bltriangle** p);
int sp_bltriangle_destroy (sp_bltriangle** p);
int sp_bltriangle_init (sp_data* sp, sp_bltriangle* p);
int sp_bltriangle_compute (sp_data* sp, sp_bltriangle* p, float* in_, float* out_);

struct sp_fold
{
    float incr;
    float index;
    int sample_index;
    float value;
}

int sp_fold_create (sp_fold** p);
int sp_fold_destroy (sp_fold** p);
int sp_fold_init (sp_data* sp, sp_fold* p);
int sp_fold_compute (sp_data* sp, sp_fold* p, float* in_, float* out_);

struct sp_bitcrush
{
    float bitdepth;
    float srate;
    sp_fold* fold;
}

int sp_bitcrush_create (sp_bitcrush** p);
int sp_bitcrush_destroy (sp_bitcrush** p);
int sp_bitcrush_init (sp_data* sp, sp_bitcrush* p);
int sp_bitcrush_compute (sp_data* sp, sp_bitcrush* p, float* in_, float* out_);

struct sp_brown
{
    float brown;
}

int sp_brown_create (sp_brown** p);
int sp_brown_destroy (sp_brown** p);
int sp_brown_init (sp_data* sp, sp_brown* p);
int sp_brown_compute (sp_data* sp, sp_brown* p, float* in_, float* out_);

struct sp_butbp
{
    float sr;
    float freq;
    float bw;
    float istor;
    float lkf;
    float lkb;
    float[8] a;
    float pidsr;
    float tpidsr;
}

int sp_butbp_create (sp_butbp** p);
int sp_butbp_destroy (sp_butbp** p);
int sp_butbp_init (sp_data* sp, sp_butbp* p);
int sp_butbp_compute (sp_data* sp, sp_butbp* p, float* in_, float* out_);

struct sp_butbr
{
    float sr;
    float freq;
    float bw;
    float istor;
    float lkf;
    float lkb;
    float[8] a;
    float pidsr;
    float tpidsr;
}

int sp_butbr_create (sp_butbr** p);
int sp_butbr_destroy (sp_butbr** p);
int sp_butbr_init (sp_data* sp, sp_butbr* p);
int sp_butbr_compute (sp_data* sp, sp_butbr* p, float* in_, float* out_);

struct sp_buthp
{
    float sr;
    float freq;
    float istor;
    float lkf;
    float[8] a;
    float pidsr;
}

int sp_buthp_create (sp_buthp** p);
int sp_buthp_destroy (sp_buthp** p);
int sp_buthp_init (sp_data* sp, sp_buthp* p);
int sp_buthp_compute (sp_data* sp, sp_buthp* p, float* in_, float* out_);

struct sp_butlp
{
    float sr;
    float freq;
    float istor;
    float lkf;
    float[8] a;
    float pidsr;
}

int sp_butlp_create (sp_butlp** p);
int sp_butlp_destroy (sp_butlp** p);
int sp_butlp_init (sp_data* sp, sp_butlp* p);
int sp_butlp_compute (sp_data* sp, sp_butlp* p, float* in_, float* out_);

struct sp_clip
{
    float lim;
    float k1;
}

int sp_clip_create (sp_clip** p);
int sp_clip_destroy (sp_clip** p);
int sp_clip_init (sp_data* sp, sp_clip* p);
int sp_clip_compute (sp_data* sp, sp_clip* p, float* in_, float* out_);

struct sp_clock
{
    float bpm;
    float subdiv;
    uint counter;
}

int sp_clock_create (sp_clock** p);
int sp_clock_destroy (sp_clock** p);
int sp_clock_init (sp_data* sp, sp_clock* p);
int sp_clock_compute (sp_data* sp, sp_clock* p, float* trig, float* out_);

struct sp_comb
{
    float revtime;
    float looptime;
    float coef;
    float prvt;
    sp_auxdata aux;
    uint bufpos;
    uint bufsize;
}

int sp_comb_create (sp_comb** p);
int sp_comb_destroy (sp_comb** p);
int sp_comb_init (sp_data* sp, sp_comb* p, float looptime);
int sp_comb_compute (sp_data* sp, sp_comb* p, float* in_, float* out_);

struct sp_compressor
{
    void* faust;
    int argpos;
    float*[4] args;
    float* ratio;
    float* thresh;
    float* atk;
    float* rel;
}

int sp_compressor_create (sp_compressor** p);
int sp_compressor_destroy (sp_compressor** p);
int sp_compressor_init (sp_data* sp, sp_compressor* p);
int sp_compressor_compute (sp_data* sp, sp_compressor* p, float* in_, float* out_);

struct sp_count
{
    int count;
    int curcount;
    int mode;
}

int sp_count_create (sp_count** p);
int sp_count_destroy (sp_count** p);
int sp_count_init (sp_data* sp, sp_count* p);
int sp_count_compute (sp_data* sp, sp_count* p, float* in_, float* out_);

struct sp_conv
{
    float[1] aOut;
    float aIn;
    float iPartLen;
    float iSkipSamples;
    float iTotLen;
    int initDone;
    int nChannels;
    int cnt;
    int nPartitions;
    int partSize;
    int rbCnt;
    float* tmpBuf;
    float* ringBuf;
    float*[1] IR_Data;
    float*[1] outBuffers;
    sp_auxdata auxData;
    sp_ftbl* ftbl;
    sp_fft fft;
}

int sp_conv_create (sp_conv** p);
int sp_conv_destroy (sp_conv** p);
int sp_conv_init (sp_data* sp, sp_conv* p, sp_ftbl* ft, float iPartLen);
int sp_conv_compute (sp_data* sp, sp_conv* p, float* in_, float* out_);

struct sp_crossfade
{
    float pos;
}

int sp_crossfade_create (sp_crossfade** p);
int sp_crossfade_destroy (sp_crossfade** p);
int sp_crossfade_init (sp_data* sp, sp_crossfade* p);
int sp_crossfade_compute (sp_data* sp, sp_crossfade* p, float* in1, float* in2, float* out_);

struct sp_dcblock
{
    float gg;
    float outputs;
    float inputs;
    float gain;
}

int sp_dcblock_create (sp_dcblock** p);
int sp_dcblock_destroy (sp_dcblock** p);
int sp_dcblock_init (sp_data* sp, sp_dcblock* p);
int sp_dcblock_compute (sp_data* sp, sp_dcblock* p, float* in_, float* out_);

struct sp_delay
{
    float time;
    float feedback;
    float last;
    sp_auxdata buf;
    uint bufsize;
    uint bufpos;
}

int sp_delay_create (sp_delay** p);
int sp_delay_destroy (sp_delay** p);
int sp_delay_init (sp_data* sp, sp_delay* p, float time);
int sp_delay_compute (sp_data* sp, sp_delay* p, float* in_, float* out_);

struct sp_diode
{
    /* 4 one-pole filters */
    float[4] opva_alpha;
    float[4] opva_beta;
    float[4] opva_gamma;
    float[4] opva_delta;
    float[4] opva_eps;
    float[4] opva_a0;
    float[4] opva_fdbk;
    float[4] opva_z1;
    /* end one-pole filters */

    float[4] SG;
    float gamma;
    float freq;
    float K;
    float res;
}

int sp_diode_create (sp_diode** p);
int sp_diode_destroy (sp_diode** p);
int sp_diode_init (sp_data* sp, sp_diode* p);
int sp_diode_compute (sp_data* sp, sp_diode* p, float* in_, float* out_);

struct sp_dist
{
    float pregain;
    float postgain;
    float shape1;
    float shape2;
    float mode;
}

int sp_dist_create (sp_dist** p);
int sp_dist_destroy (sp_dist** p);
int sp_dist_init (sp_data* sp, sp_dist* p);
int sp_dist_compute (sp_data* sp, sp_dist* p, float* in_, float* out_);

struct sp_dmetro
{
    float time;
    uint counter;
}

int sp_dmetro_create (sp_dmetro** p);
int sp_dmetro_destroy (sp_dmetro** p);
int sp_dmetro_init (sp_data* sp, sp_dmetro* p);
int sp_dmetro_compute (sp_data* sp, sp_dmetro* p, float* in_, float* out_);

struct sp_drip
{
    float amp; /* How loud */
    float dettack; /* How loud */
    float num_tubes;
    float damp;
    float shake_max;
    float freq;
    float freq1;
    float freq2;

    float num_objectsSave;
    float shake_maxSave;
    float shakeEnergy;
    float outputs00;
    float outputs01;
    float outputs10;
    float outputs11;
    float outputs20;
    float outputs21;
    float coeffs00;
    float coeffs01;
    float coeffs10;
    float coeffs11;
    float coeffs20;
    float coeffs21;
    float finalZ0;
    float finalZ1;
    float finalZ2;
    float sndLevel;
    float gains0;
    float gains1;
    float gains2;
    float center_freqs0;
    float center_freqs1;
    float center_freqs2;
    float soundDecay;
    float systemDecay;
    float num_objects;
    float totalEnergy;
    float decayScale;
    float res_freq0;
    float res_freq1;
    float res_freq2;
    float shake_damp;
    int kloop;
}

int sp_drip_create (sp_drip** p);
int sp_drip_destroy (sp_drip** p);
int sp_drip_init (sp_data* sp, sp_drip* p, float dettack);
int sp_drip_compute (sp_data* sp, sp_drip* p, float* trig, float* out_);

struct sp_dtrig
{
    sp_ftbl* ft;
    uint counter;
    uint pos;
    int running;
    int loop;
    float delay;
    float scale;
}

int sp_dtrig_create (sp_dtrig** p);
int sp_dtrig_destroy (sp_dtrig** p);
int sp_dtrig_init (sp_data* sp, sp_dtrig* p, sp_ftbl* ft);
int sp_dtrig_compute (sp_data* sp, sp_dtrig* p, float* in_, float* out_);

struct sp_dust
{
    float amp;
    float density;
    float density0;
    float thresh;
    float scale;
    float onedsr;
    int bipolar; /* 1 = bipolar 0 = unipolar */
    uint rand;
}

int sp_dust_create (sp_dust** p);
int sp_dust_destroy (sp_dust** p);
int sp_dust_init (sp_data* sp, sp_dust* p);
int sp_dust_compute (sp_data* sp, sp_dust* p, float* in_, float* out_);

struct sp_eqfil
{
    float freq;
    float bw;
    float gain;
    float z1;
    float z2;
    float sr;
    float frv;
    float bwv;
    float c;
    float d;
}

int sp_eqfil_create (sp_eqfil** p);
int sp_eqfil_destroy (sp_eqfil** p);
int sp_eqfil_init (sp_data* sp, sp_eqfil* p);
int sp_eqfil_compute (sp_data* sp, sp_eqfil* p, float* in_, float* out_);

struct sp_expon
{
    float a;
    float dur;
    float b;
    float val;
    float incr;
    uint sdur;
    uint stime;
    int init;
}

int sp_expon_create (sp_expon** p);
int sp_expon_destroy (sp_expon** p);
int sp_expon_init (sp_data* sp, sp_expon* p);
int sp_expon_compute (sp_data* sp, sp_expon* p, float* in_, float* out_);

struct sp_fof_overlap
{
    sp_fof_overlap* nxtact;
    sp_fof_overlap* nxtfree;
    int timrem;
    int dectim;
    int formphs;
    int forminc;
    int risphs;
    int risinc;
    int decphs;
    int decinc;
    float curamp;
    float expamp;
    float glissbas;
    int sampct;
}

struct sp_fof
{
    float amp;
    float fund;
    float form;
    float oct;
    float band;
    float ris;
    float dur;
    float dec;
    float iolaps;
    float iphs;
    int durtogo;
    int fundphs;
    int fofcount;
    int prvsmps;
    float prvband;
    float expamp;
    float preamp;
    short foftype;
    short xincod;
    short ampcod;
    short fundcod;
    short formcod;
    short fmtmod;
    sp_auxdata auxch;
    sp_ftbl* ftp1;
    sp_ftbl* ftp2;
    sp_fof_overlap basovrlap;
}

int sp_fof_create (sp_fof** p);
int sp_fof_destroy (sp_fof** p);
int sp_fof_init (sp_data* sp, sp_fof* p, sp_ftbl* sine, sp_ftbl* win, int iolaps, float iphs);
int sp_fof_compute (sp_data* sp, sp_fof* p, float* in_, float* out_);

struct sp_fog_overlap
{
    sp_fog_overlap* nxtact;
    sp_fog_overlap* nxtfree;
    int timrem;
    int dectim;
    int formphs;
    int forminc;
    uint risphs;
    int risinc;
    int decphs;
    int decinc;
    float curamp;
    float expamp;
    float pos;
    float inc;
}

struct sp_fog
{
    float amp;
    float dens;
    float trans;
    float spd;
    float oct;
    float band;
    float ris;
    float dur;
    float dec;
    float iolaps;
    float iphs;
    float itmode;
    sp_fog_overlap basovrlap;
    int durtogo;
    int fundphs;
    int fofcount;
    int prvsmps;
    int spdphs;
    float prvband;
    float expamp;
    float preamp;
    float fogcvt;
    short formcod;
    short fmtmod;
    short speedcod;
    sp_auxdata auxch;
    sp_ftbl* ftp1;
    sp_ftbl* ftp2;
}

int sp_fog_create (sp_fog** p);
int sp_fog_destroy (sp_fog** p);
int sp_fog_init (sp_data* sp, sp_fog* p, sp_ftbl* wav, sp_ftbl* win, int iolaps, float iphs);
int sp_fog_compute (sp_data* sp, sp_fog* p, float* in_, float* out_);

struct sp_fofilt
{
    float freq;
    float atk;
    float dec;
    float istor;
    float tpidsr;
    float sr;
    float[4] delay;
}

int sp_fofilt_create (sp_fofilt** t);
int sp_fofilt_destroy (sp_fofilt** t);
int sp_fofilt_init (sp_data* sp, sp_fofilt* p);
int sp_fofilt_compute (sp_data* sp, sp_fofilt* p, float* in_, float* out_);

struct sp_foo
{
    float bar;
}

int sp_foo_create (sp_foo** p);
int sp_foo_destroy (sp_foo** p);
int sp_foo_init (sp_data* sp, sp_foo* p);
int sp_foo_compute (sp_data* sp, sp_foo* p, float* in_, float* out_);

struct sp_fosc
{
    float amp;
    float freq;
    float car;
    float mod;
    float indx;
    float iphs;
    int mphs;
    int cphs;
    sp_ftbl* ft;
}

int sp_fosc_create (sp_fosc** p);
int sp_fosc_destroy (sp_fosc** p);
int sp_fosc_init (sp_data* sp, sp_fosc* p, sp_ftbl* ft);
int sp_fosc_compute (sp_data* sp, sp_fosc* p, float* in_, float* out_);

struct sp_gbuzz
{
    float amp;
    float freq;
    float nharm;
    float lharm;
    float mul;
    float iphs;
    short ampcod;
    short cpscod;
    short prvn;
    float prvr;
    float twor;
    float rsqp1;
    float rtn;
    float rtnp1;
    float rsumr;
    int lphs;
    int reported;
    float last;
    sp_ftbl* ft;
}

int sp_gbuzz_create (sp_gbuzz** p);
int sp_gbuzz_destroy (sp_gbuzz** p);
int sp_gbuzz_init (sp_data* sp, sp_gbuzz* p, sp_ftbl* ft, float iphs);
int sp_gbuzz_compute (sp_data* sp, sp_gbuzz* p, float* in_, float* out_);

struct sp_hilbert
{
    float[12] xnm1;
    float[12] ynm1;
    float[12] coef;
}

int sp_hilbert_create (sp_hilbert** p);
int sp_hilbert_destroy (sp_hilbert** p);
int sp_hilbert_init (sp_data* sp, sp_hilbert* p);
int sp_hilbert_compute (sp_data* sp, sp_hilbert* p, float* in_, float* out1, float* out2);

struct sp_in
{
    FILE* fp;
}

int sp_in_create (sp_in** p);
int sp_in_destroy (sp_in** p);
int sp_in_init (sp_data* sp, sp_in* p);
int sp_in_compute (sp_data* sp, sp_in* p, float* in_, float* out_);

struct sp_incr
{
    float step;
    float min;
    float max;
    float val;
}

int sp_incr_create (sp_incr** p);
int sp_incr_destroy (sp_incr** p);
int sp_incr_init (sp_data* sp, sp_incr* p, float val);
int sp_incr_compute (sp_data* sp, sp_incr* p, float* in_, float* out_);

struct sp_jcrev
{
    void* ud;
}

int sp_jcrev_create (sp_jcrev** p);
int sp_jcrev_destroy (sp_jcrev** p);
int sp_jcrev_init (sp_data* sp, sp_jcrev* p);
int sp_jcrev_compute (sp_data* sp, sp_jcrev* p, float* in_, float* out_);

struct sp_jitter
{
    float amp;
    float cpsMin;
    float cpsMax;
    float cps;
    int phs;
    int initflag;
    float num1;
    float num2;
    float dfdmax;
}

int sp_jitter_create (sp_jitter** p);
int sp_jitter_destroy (sp_jitter** p);
int sp_jitter_init (sp_data* sp, sp_jitter* p);
int sp_jitter_compute (sp_data* sp, sp_jitter* p, float* in_, float* out_);

struct sp_line
{
    float a;
    float dur;
    float b;
    float val;
    float incr;
    uint sdur;
    uint stime;
    int init;
}

int sp_line_create (sp_line** p);
int sp_line_destroy (sp_line** p);
int sp_line_init (sp_data* sp, sp_line* p);
int sp_line_compute (sp_data* sp, sp_line* p, float* in_, float* out_);

struct sp_lpc
{
    struct openlpc_e_state;
    openlpc_e_state* e;
    struct openlpc_d_state;
    openlpc_d_state* d;
    int counter;
    short* in_;
    short* out_;
    ubyte[7] data;
    float[7] y;
    float smooth;
    float samp;
    uint clock;
    uint block;
    int framesize;
    sp_auxdata m_in;
    sp_auxdata m_out;
    sp_auxdata m_e;
    sp_auxdata m_d;
    int mode;
    sp_ftbl* ft;
}

int sp_lpc_create (sp_lpc** lpc);
int sp_lpc_destroy (sp_lpc** lpc);
int sp_lpc_init (sp_data* sp, sp_lpc* lpc, int framesize);
int sp_lpc_synth (sp_data* sp, sp_lpc* lpc, sp_ftbl* ft);
int sp_lpc_compute (sp_data* sp, sp_lpc* lpc, float* in_, float* out_);

struct sp_lpf18
{
    float cutoff;
    float res;
    float dist;
    float ay1;
    float ay2;
    float aout;
    float lastin;
    float onedsr;
}

int sp_lpf18_create (sp_lpf18** p);
int sp_lpf18_destroy (sp_lpf18** p);
int sp_lpf18_init (sp_data* sp, sp_lpf18* p);
int sp_lpf18_compute (sp_data* sp, sp_lpf18* p, float* in_, float* out_);

struct sp_maygate
{
    float prob;
    float gate;
    int mode;
}

int sp_maygate_create (sp_maygate** p);
int sp_maygate_destroy (sp_maygate** p);
int sp_maygate_init (sp_data* sp, sp_maygate* p);
int sp_maygate_compute (sp_data* sp, sp_maygate* p, float* in_, float* out_);

struct sp_metro
{
    float sr;
    float freq;
    float iphs;
    float curphs;
    int flag;
    float onedsr;
}

int sp_metro_create (sp_metro** p);
int sp_metro_destroy (sp_metro** p);
int sp_metro_init (sp_data* sp, sp_metro* p);
int sp_metro_compute (sp_data* sp, sp_metro* p, float* in_, float* out_);

struct sp_mincer
{
    float time;
    float amp;
    float pitch;
    float lock;
    float iN;
    float idecim;
    float onset;
    float offset;
    float dbthresh;
    int cnt;
    int hsize;
    int curframe;
    int N;
    int decim;
    int tscale;
    float pos;
    float accum;
    sp_auxdata outframe;
    sp_auxdata win;
    sp_auxdata bwin;
    sp_auxdata fwin;
    sp_auxdata nwin;
    sp_auxdata prev;
    sp_auxdata framecount;
    sp_auxdata[2] indata;
    float* tab;
    int curbuf;
    float resamp;
    sp_ftbl* ft;
    sp_fft fft;
}

int sp_mincer_create (sp_mincer** p);
int sp_mincer_destroy (sp_mincer** p);
int sp_mincer_init (sp_data* sp, sp_mincer* p, sp_ftbl* ft, int winsize);
int sp_mincer_compute (sp_data* sp, sp_mincer* p, float* in_, float* out_);

struct sp_mode
{
    float freq;
    float q;
    float xnm1;
    float ynm1;
    float ynm2;
    float a0;
    float a1;
    float a2;
    float d;
    float lfq;
    float lq;
    float sr;
}

int sp_mode_create (sp_mode** p);
int sp_mode_destroy (sp_mode** p);
int sp_mode_init (sp_data* sp, sp_mode* p);
int sp_mode_compute (sp_data* sp, sp_mode* p, float* in_, float* out_);

struct sp_moogladder
{
    float freq;
    float res;
    float istor;

    float[6] delay;
    float[3] tanhstg;
    float oldfreq;
    float oldres;
    float oldacr;
    float oldtune;
}

int sp_moogladder_create (sp_moogladder** t);
int sp_moogladder_destroy (sp_moogladder** t);
int sp_moogladder_init (sp_data* sp, sp_moogladder* p);
int sp_moogladder_compute (sp_data* sp, sp_moogladder* p, float* in_, float* out_);

struct sp_noise
{
    float amp;
}

int sp_noise_create (sp_noise** ns);
int sp_noise_init (sp_data* sp, sp_noise* ns);
int sp_noise_compute (sp_data* sp, sp_noise* ns, float* in_, float* out_);
int sp_noise_destroy (sp_noise** ns);

struct nano_entry
{
    char[50] name;
    uint pos;
    uint size;
    float speed;
    nano_entry* next;
}

struct nano_dict
{
    int nval;
    int init;
    nano_entry root;
    nano_entry* last;
}

struct nanosamp
{
    char[100] ini;
    float curpos;
    nano_dict dict;
    int selected;
    nano_entry* sample;
    nano_entry** index;
    sp_ftbl* ft;
    int sr;
}

struct sp_nsmp
{
    nanosamp* smp;
    uint index;
    int triggered;
}

int sp_nsmp_create (sp_nsmp** p);
int sp_nsmp_destroy (sp_nsmp** p);
int sp_nsmp_init (sp_data* sp, sp_nsmp* p, sp_ftbl* ft, int sr, const(char)* ini);
int sp_nsmp_compute (sp_data* sp, sp_nsmp* p, float* in_, float* out_);

int sp_nsmp_print_index (sp_data* sp, sp_nsmp* p);

struct sp_osc
{
    float freq;
    float amp;
    float iphs;
    int lphs;
    sp_ftbl* tbl;
    int inc;
}

int sp_osc_create (sp_osc** osc);
int sp_osc_destroy (sp_osc** osc);
int sp_osc_init (sp_data* sp, sp_osc* osc, sp_ftbl* ft, float iphs);
int sp_osc_compute (sp_data* sp, sp_osc* osc, float* in_, float* out_);

struct sp_oscmorph
{
    float freq;
    float amp;
    float iphs;
    int lphs;
    sp_ftbl** tbl;
    int inc;
    float wtpos;
    int nft;
}

int sp_oscmorph_create (sp_oscmorph** p);
int sp_oscmorph_destroy (sp_oscmorph** p);
int sp_oscmorph_init (sp_data* sp, sp_oscmorph* osc, sp_ftbl** ft, int nft, float iphs);
int sp_oscmorph_compute (sp_data* sp, sp_oscmorph* p, float* in_, float* out_);

struct sp_pan2
{
    float pan;
    uint type;
}

int sp_pan2_create (sp_pan2** p);
int sp_pan2_destroy (sp_pan2** p);
int sp_pan2_init (sp_data* sp, sp_pan2* p);
int sp_pan2_compute (sp_data* sp, sp_pan2* p, float* in_, float* out1, float* out2);

struct sp_panst
{
    float pan;
    uint type;
}

int sp_panst_create (sp_panst** p);
int sp_panst_destroy (sp_panst** p);
int sp_panst_init (sp_data* sp, sp_panst* p);
int sp_panst_compute (sp_data* sp, sp_panst* p, float* in1, float* in2, float* out1, float* out2);

struct sp_pareq
{
    float fc;
    float v;
    float q;
    float mode;

    float xnm1;
    float xnm2;
    float ynm1;
    float ynm2;
    float prv_fc;
    float prv_v;
    float prv_q;
    float b0;
    float b1;
    float b2;
    float a1;
    float a2;
    float tpidsr;
    int imode;
}

int sp_pareq_create (sp_pareq** p);
int sp_pareq_destroy (sp_pareq** p);
int sp_pareq_init (sp_data* sp, sp_pareq* p);
int sp_pareq_compute (sp_data* sp, sp_pareq* p, float* in_, float* out_);

struct sp_paulstretch
{
    uint windowsize;
    uint half_windowsize;
    float stretch;
    float start_pos;
    float displace_pos;
    float* window;
    float* old_windowed_buf;
    float* hinv_buf;
    float* buf;
    float* output;
    sp_ftbl* ft;
    kiss_fftr_cfg fft;
    kiss_fftr_cfg ifft;
    kiss_fft_cpx* tmp1;
    kiss_fft_cpx* tmp2;
    uint counter;
    sp_auxdata m_window;
    sp_auxdata m_old_windowed_buf;
    sp_auxdata m_hinv_buf;
    sp_auxdata m_buf;
    sp_auxdata m_output;
    ubyte wrap;
}

int sp_paulstretch_create (sp_paulstretch** p);
int sp_paulstretch_destroy (sp_paulstretch** p);
int sp_paulstretch_init (sp_data* sp, sp_paulstretch* p, sp_ftbl* ft, float windowsize, float stretch);
int sp_paulstretch_compute (sp_data* sp, sp_paulstretch* p, float* in_, float* out_);

struct sp_pdhalf
{
    float amount;
    float ibipolar;
    float ifullscale;
}

int sp_pdhalf_create (sp_pdhalf** p);
int sp_pdhalf_destroy (sp_pdhalf** p);
int sp_pdhalf_init (sp_data* sp, sp_pdhalf* p);
int sp_pdhalf_compute (sp_data* sp, sp_pdhalf* p, float* in_, float* out_);

struct sp_peaklim
{
    float atk;
    float rel;
    float thresh;
    float patk;
    float prel;
    float b0_r;
    float a1_r;
    float b0_a;
    float a1_a;
    float level;
}

int sp_peaklim_create (sp_peaklim** p);
int sp_peaklim_destroy (sp_peaklim** p);
int sp_peaklim_init (sp_data* sp, sp_peaklim* p);
int sp_peaklim_compute (sp_data* sp, sp_peaklim* p, float* in_, float* out_);

struct sp_phaser
{
    void* faust;
    int argpos;
    float*[10] args;
    float* MaxNotch1Freq;
    float* MinNotch1Freq;
    float* Notch_width;
    float* NotchFreq;
    float* VibratoMode;
    float* depth;
    float* feedback_gain;
    float* invert;
    float* level;
    float* lfobpm;
}

int sp_phaser_create (sp_phaser** p);
int sp_phaser_destroy (sp_phaser** p);
int sp_phaser_init (sp_data* sp, sp_phaser* p);
int sp_phaser_compute (
    sp_data* sp,
    sp_phaser* p,
    float* in1,
    float* in2,
    float* out1,
    float* out2);

struct sp_phasor
{
    float freq;
    float phs;
    float curphs;
    float onedsr;
}

int sp_phasor_create (sp_phasor** p);
int sp_phasor_destroy (sp_phasor** p);
int sp_phasor_init (sp_data* sp, sp_phasor* p, float iphs);
int sp_phasor_compute (sp_data* sp, sp_phasor* p, float* in_, float* out_);

struct sp_pinknoise
{
    float amp;
    uint newrand;
    uint prevrand;
    uint k;
    uint seed;
    uint total;
    uint counter;
    uint[7] dice;
}

int sp_pinknoise_create (sp_pinknoise** p);
int sp_pinknoise_destroy (sp_pinknoise** p);
int sp_pinknoise_init (sp_data* sp, sp_pinknoise* p);
int sp_pinknoise_compute (sp_data* sp, sp_pinknoise* p, float* in_, float* out_);

struct sp_pitchamdf
{
    float imincps;
    float imaxcps;
    float icps;
    float imedi;
    float idowns;
    float iexcps;
    float irmsmedi;
    float srate;
    float lastval;
    int downsamp;
    int upsamp;
    int minperi;
    int maxperi;
    int index;
    int readp;
    int size;
    int peri;
    int medisize;
    int mediptr;
    int rmsmedisize;
    int rmsmediptr;
    int inerr;
    sp_auxdata median;
    sp_auxdata rmsmedian;
    sp_auxdata buffer;
}

int sp_pitchamdf_create (sp_pitchamdf** p);
int sp_pitchamdf_destroy (sp_pitchamdf** p);
int sp_pitchamdf_init (sp_data* sp, sp_pitchamdf* p, float imincps, float imaxcps);
int sp_pitchamdf_compute (sp_data* sp, sp_pitchamdf* p, float* in_, float* cps, float* rms);

struct sp_pluck
{
    float amp;
    float freq;
    float ifreq;
    float sicps;
    int phs256;
    int npts;
    int maxpts;
    sp_auxdata auxch;
    char init;
}

int sp_pluck_create (sp_pluck** p);
int sp_pluck_destroy (sp_pluck** p);
int sp_pluck_init (sp_data* sp, sp_pluck* p, float ifreq);
int sp_pluck_compute (sp_data* sp, sp_pluck* p, float* trig, float* out_);

struct sp_port
{
    float htime;
    float c1;
    float c2;
    float yt1;
    float prvhtim;
    float sr;
    float onedsr;
}

int sp_port_create (sp_port** p);
int sp_port_destroy (sp_port** p);
int sp_port_init (sp_data* sp, sp_port* p, float htime);
int sp_port_compute (sp_data* sp, sp_port* p, float* in_, float* out_);
int sp_port_reset (sp_data* sp, sp_port* p, float* in_);

struct sp_posc3
{
    float freq;
    float amp;
    float iphs;
    sp_ftbl* tbl;
    int tablen;
    float tablenUPsr;
    float phs;
    float onedsr;
}

int sp_posc3_create (sp_posc3** posc3);
int sp_posc3_destroy (sp_posc3** posc3);
int sp_posc3_init (sp_data* sp, sp_posc3* posc3, sp_ftbl* ft);
int sp_posc3_compute (sp_data* sp, sp_posc3* posc3, float* in_, float* out_);

struct sp_progress
{
    int nbars;
    int skip;
    int counter;
    uint len;
}

int sp_progress_create (sp_progress** p);
int sp_progress_destroy (sp_progress** p);
int sp_progress_init (sp_data* sp, sp_progress* p);
int sp_progress_compute (sp_data* sp, sp_progress* p, float* in_, float* out_);

struct prop_event
{
    char type;
    uint pos;
    uint val;
    uint cons;
}

struct prop_val
{
    char type;
    void* ud;
}

struct prop_entry
{
    prop_val val;
    prop_entry* next;
}

struct prop_list
{
    prop_entry root;
    prop_entry* last;
    uint size;
    uint pos;
    prop_list* top;
    uint lvl;
}

struct prop_stack
{
    uint[16] stack;
    int pos;
}

struct prop_data
{
    uint mul;
    uint div;
    uint tmp;
    uint cons_mul;
    uint cons_div;
    float scale;
    int mode;
    uint pos;
    prop_list top;
    prop_list* main;
    prop_stack mstack;
    prop_stack cstack;
}

struct sp_prop
{
    prop_data* prp;
    prop_event evt;
    uint count;
    float bpm;
    float lbpm;
}

int sp_prop_create (sp_prop** p);
int sp_prop_destroy (sp_prop** p);
int sp_prop_reset (sp_data* sp, sp_prop* p);
int sp_prop_init (sp_data* sp, sp_prop* p, const(char)* str);
int sp_prop_compute (sp_data* sp, sp_prop* p, float* in_, float* out_);

struct sp_pshift
{
    void* faust;
    int argpos;
    float*[3] args;
    float* shift;
    float* window;
    float* xfade;
}

int sp_pshift_create (sp_pshift** p);
int sp_pshift_destroy (sp_pshift** p);
int sp_pshift_init (sp_data* sp, sp_pshift* p);
int sp_pshift_compute (sp_data* sp, sp_pshift* p, float* in_, float* out_);

struct sp_ptrack
{
    float freq;
    float amp;
    float asig;
    float size;
    float peak;
    sp_auxdata signal;
    sp_auxdata prev;
    sp_auxdata sin;
    sp_auxdata spec1;
    sp_auxdata spec2;
    sp_auxdata peakarray;
    int numpks;
    int cnt;
    int histcnt;
    int hopsize;
    float sr;
    float cps;
    float[20] dbs;
    float amplo;
    float amphi;
    float npartial;
    float dbfs;
    float prevf;
    sp_fft fft;
}

int sp_ptrack_create (sp_ptrack** p);
int sp_ptrack_destroy (sp_ptrack** p);
int sp_ptrack_init (sp_data* sp, sp_ptrack* p, int ihopsize, int ipeaks);
int sp_ptrack_compute (sp_data* sp, sp_ptrack* p, float* in_, float* freq, float* amp);

struct sp_randh
{
    float freq;
    float min;
    float max;
    float val;
    uint counter;
    uint dur;
}

int sp_randh_create (sp_randh** p);
int sp_randh_destroy (sp_randh** p);
int sp_randh_init (sp_data* sp, sp_randh* p);
int sp_randh_compute (sp_data* sp, sp_randh* p, float* in_, float* out_);

struct sp_randi
{
    float min;
    float max;
    float cps;
    float mode;
    float fstval;
    short cpscod;
    int phs;
    float num1;
    float num2;
    float dfdmax;
    int holdrand;
    float sicvt;
}

int sp_randi_create (sp_randi** p);
int sp_randi_destroy (sp_randi** p);
int sp_randi_init (sp_data* sp, sp_randi* p);
int sp_randi_compute (sp_data* sp, sp_randi* p, float* in_, float* out_);

struct sp_randmt
{
    int mti;
    /* do not change value 624 */
    uint[624] mt;
}

void sp_randmt_seed (sp_randmt* p, const(uint)* initKey, uint keyLength);

uint sp_randmt_compute (sp_randmt* p);

struct sp_random
{
    float min;
    float max;
}

int sp_random_create (sp_random** p);
int sp_random_destroy (sp_random** p);
int sp_random_init (sp_data* sp, sp_random* p);
int sp_random_compute (sp_data* sp, sp_random* p, float* in_, float* out_);

struct sp_reverse
{
    float delay;
    uint bufpos;
    uint bufsize;
    sp_auxdata buf;
}

int sp_reverse_create (sp_reverse** p);
int sp_reverse_destroy (sp_reverse** p);
int sp_reverse_init (sp_data* sp, sp_reverse* p, float delay);
int sp_reverse_compute (sp_data* sp, sp_reverse* p, float* in_, float* out_);

struct sp_reson
{
    float freq;
    float bw;
    int scale;
    float c1;
    float c2;
    float c3;
    float yt1;
    float yt2;
    float cosf;
    float prvfreq;
    float prvbw;
    float tpidsr;
}

int sp_reson_create (sp_reson** p);
int sp_reson_destroy (sp_reson** p);
int sp_reson_init (sp_data* sp, sp_reson* p);
int sp_reson_compute (sp_data* sp, sp_reson* p, float* in_, float* out_);

struct sp_revsc_dl
{
    int writePos;
    int bufferSize;
    int readPos;
    int readPosFrac;
    int readPosFrac_inc;
    int dummy;
    int seedVal;
    int randLine_cnt;
    float filterState;
    float* buf;
}

struct sp_revsc
{
    float feedback;
    float lpfreq;
    float iSampleRate;
    float iPitchMod;
    float iSkipInit;
    float sampleRate;
    float dampFact;
    float prv_LPFreq;
    int initDone;
    sp_revsc_dl[8] delayLines;
    sp_auxdata aux;
}

int sp_revsc_create (sp_revsc** p);
int sp_revsc_destroy (sp_revsc** p);
int sp_revsc_init (sp_data* sp, sp_revsc* p);
int sp_revsc_compute (sp_data* sp, sp_revsc* p, float* in1, float* in2, float* out1, float* out2);

struct sp_rms
{
    float ihp;
    float istor;
    float c1;
    float c2;
    float prvq;
}

int sp_rms_create (sp_rms** p);
int sp_rms_destroy (sp_rms** p);
int sp_rms_init (sp_data* sp, sp_rms* p);
int sp_rms_compute (sp_data* sp, sp_rms* p, float* in_, float* out_);

struct sp_rpt
{
    uint playpos;
    uint bufpos;
    int running;
    int count;
    int reps;
    float sr;
    uint size;
    float bpm;
    int div;
    int rep;
    sp_auxdata aux;
    int rc;
}

int sp_rpt_create (sp_rpt** p);
int sp_rpt_destroy (sp_rpt** p);
int sp_rpt_init (sp_data* sp, sp_rpt* p, float maxdur);
int sp_rpt_compute (
    sp_data* sp,
    sp_rpt* p,
    float* trig,
    float* in_,
    float* out_);

struct sp_rspline
{
    float min;
    float max;
    float cps_min;
    float cps_max;
    float si;
    float phs;
    int rmin_cod;
    int rmax_cod;
    float num0;
    float num1;
    float num2;
    float df0;
    float df1;
    float c3;
    float c2;
    float onedsr;
    int holdrand;
    int init;
}

int sp_rspline_create (sp_rspline** p);
int sp_rspline_destroy (sp_rspline** p);
int sp_rspline_init (sp_data* sp, sp_rspline* p);
int sp_rspline_compute (sp_data* sp, sp_rspline* p, float* in_, float* out_);

struct sp_saturator
{
    float drive;
    float dcoffset;

    float[7][2] dcblocker;

    float[7][6] ai;
    float[7][6] aa;
}

int sp_saturator_create (sp_saturator** p);
int sp_saturator_destroy (sp_saturator** p);
int sp_saturator_init (sp_data* sp, sp_saturator* p);
int sp_saturator_compute (sp_data* sp, sp_saturator* p, float* in_, float* out_);

struct sp_samphold
{
    float val;
}

int sp_samphold_create (sp_samphold** p);
int sp_samphold_destroy (sp_samphold** p);
int sp_samphold_init (sp_data* sp, sp_samphold* p);
int sp_samphold_compute (sp_data* sp, sp_samphold* p, float* trig, float* in_, float* out_);

struct sp_scale
{
    float min;
    float max;
}

int sp_scale_create (sp_scale** p);
int sp_scale_destroy (sp_scale** p);
int sp_scale_init (sp_data* sp, sp_scale* p);
int sp_scale_compute (sp_data* sp, sp_scale* p, float* in_, float* out_);
int sp_gen_scrambler (sp_data* sp, sp_ftbl* src, sp_ftbl** dest);

struct sp_sdelay
{
    int size;
    int pos;
    float* buf;
}

int sp_sdelay_create (sp_sdelay** p);
int sp_sdelay_destroy (sp_sdelay** p);
int sp_sdelay_init (sp_data* sp, sp_sdelay* p, int size);
int sp_sdelay_compute (sp_data* sp, sp_sdelay* p, float* in_, float* out_);

struct sp_slice
{
    sp_ftbl* vals;
    sp_ftbl* buf;
    uint id;
    uint pos;
    uint nextpos;
}

int sp_slice_create (sp_slice** p);
int sp_slice_destroy (sp_slice** p);
int sp_slice_init (sp_data* sp, sp_slice* p, sp_ftbl* vals, sp_ftbl* buf);
int sp_slice_compute (sp_data* sp, sp_slice* p, float* in_, float* out_);

struct sp_smoothdelay
{
    float del;
    float maxdel;
    float pdel;
    float sr;
    float feedback;

    int counter;
    int maxcount;

    uint maxbuf;

    sp_auxdata buf1;
    uint bufpos1;
    uint deltime1;

    sp_auxdata buf2;
    uint bufpos2;
    uint deltime2;
    int curbuf;
}

int sp_smoothdelay_create (sp_smoothdelay** p);
int sp_smoothdelay_destroy (sp_smoothdelay** p);
int sp_smoothdelay_init (
    sp_data* sp,
    sp_smoothdelay* p,
    float maxdel,
    uint interp);
int sp_smoothdelay_compute (sp_data* sp, sp_smoothdelay* p, float* in_, float* out_);

struct sp_spa
{
    float* buf;
    uint pos;
    uint bufsize;
    sp_audio spa;
    sp_auxdata aux;
}

int sp_spa_create (sp_spa** p);
int sp_spa_destroy (sp_spa** p);
int sp_spa_init (sp_data* sp, sp_spa* p, const(char)* filename);
int sp_spa_compute (sp_data* sp, sp_spa* p, float* in_, float* out_);

struct sp_sparec
{
    float* buf;
    uint pos;
    uint bufsize;
    sp_audio spa;
    sp_auxdata aux;
}

int sp_sparec_create (sp_sparec** p);
int sp_sparec_destroy (sp_sparec** p);
int sp_sparec_init (sp_data* sp, sp_sparec* p, const(char)* filename);
int sp_sparec_compute (sp_data* sp, sp_sparec* p, float* in_, float* out_);
int sp_sparec_close (sp_data* sp, sp_sparec* p);

struct sp_streson
{
    float freq;
    float fdbgain;
    float LPdelay;
    float APdelay;
    float* Cdelay;
    sp_auxdata buf;
    int wpointer;
    int rpointer;
    int size;
}

int sp_streson_create (sp_streson** p);
int sp_streson_destroy (sp_streson** p);
int sp_streson_init (sp_data* sp, sp_streson* p);
int sp_streson_compute (sp_data* sp, sp_streson* p, float* in_, float* out_);

struct sp_switch
{
    float mode;
}

int sp_switch_create (sp_switch** p);
int sp_switch_destroy (sp_switch** p);
int sp_switch_init (sp_data* sp, sp_switch* p);
int sp_switch_compute (
    sp_data* sp,
    sp_switch* p,
    float* trig,
    float* in1,
    float* in2,
    float* out_);

struct sp_tabread
{
    float sig;
    float index;
    float mode;
    float offset;
    float wrap;
    float mul;
    sp_ftbl* ft;
}

int sp_tabread_create (sp_tabread** p);
int sp_tabread_destroy (sp_tabread** p);
int sp_tabread_init (sp_data* sp, sp_tabread* p, sp_ftbl* ft, int mode);
int sp_tabread_compute (sp_data* sp, sp_tabread* p, float* in_, float* out_);

struct sp_tadsr
{
    float value;
    float target;
    float rate;
    int state;
    float attackRate;
    float decayRate;
    float sustainLevel;
    float releaseRate;
    float atk;
    float rel;
    float sus;
    float dec;
    int mode;
}

int sp_tadsr_create (sp_tadsr** p);
int sp_tadsr_destroy (sp_tadsr** p);
int sp_tadsr_init (sp_data* sp, sp_tadsr* p);
int sp_tadsr_compute (sp_data* sp, sp_tadsr* p, float* trig, float* out_);

enum SP_TALKBOX_BUFMAX = 1600;

struct sp_talkbox
{
    float quality;
    float d0;
    float d1;
    float d2;
    float d3;
    float d4;
    float u0;
    float u1;
    float u2;
    float u3;
    float u4;
    float FX;
    float emphasis;
    float[SP_TALKBOX_BUFMAX] car0;
    float[SP_TALKBOX_BUFMAX] car1;
    float[SP_TALKBOX_BUFMAX] window;
    float[SP_TALKBOX_BUFMAX] buf0;
    float[SP_TALKBOX_BUFMAX] buf1;
    uint K;
    uint N;
    uint O;
    uint pos;
}

int sp_talkbox_create (sp_talkbox** p);
int sp_talkbox_destroy (sp_talkbox** p);
int sp_talkbox_init (sp_data* sp, sp_talkbox* p);
int sp_talkbox_compute (sp_data* sp, sp_talkbox* p, float* src, float* exc, float* out_);

struct sp_tblrec
{
    sp_ftbl* ft;
    uint index;
    int record;
}

int sp_tblrec_create (sp_tblrec** p);
int sp_tblrec_destroy (sp_tblrec** p);
int sp_tblrec_init (sp_data* sp, sp_tblrec* p, sp_ftbl* ft);
int sp_tblrec_compute (sp_data* sp, sp_tblrec* p, float* in_, float* trig, float* out_);

struct sp_tbvcf
{
    float fco;
    float res;
    float dist;
    float asym;
    float iskip;
    float y;
    float y1;
    float y2;
    int fcocod;
    int rezcod;
    float sr;
    float onedsr;
}

int sp_tbvcf_create (sp_tbvcf** p);
int sp_tbvcf_destroy (sp_tbvcf** p);
int sp_tbvcf_init (sp_data* sp, sp_tbvcf* p);
int sp_tbvcf_compute (sp_data* sp, sp_tbvcf* p, float* in_, float* out_);

struct sp_tdiv
{
    uint num;
    uint counter;
    uint offset;
}

int sp_tdiv_create (sp_tdiv** p);
int sp_tdiv_destroy (sp_tdiv** p);
int sp_tdiv_init (sp_data* sp, sp_tdiv* p);
int sp_tdiv_compute (sp_data* sp, sp_tdiv* p, float* in_, float* out_);

struct sp_tenv
{
    sp_tevent* te;
    uint pos;
    uint atk_end;
    uint rel_start;
    uint sr;
    uint totaldur;
    float atk;
    float rel;
    float hold;
    float atk_slp;
    float rel_slp;
    float last;
    int sigmode;
    float input;
}

int sp_tenv_create (sp_tenv** p);
int sp_tenv_destroy (sp_tenv** p);
int sp_tenv_init (sp_data* sp, sp_tenv* p);
int sp_tenv_compute (sp_data* sp, sp_tenv* p, float* in_, float* out_);

struct sp_tenv2
{
    int state;
    float atk;
    float rel;
    uint totaltime;
    uint timer;
    float slope;
    float last;
}

int sp_tenv2_create (sp_tenv2** p);
int sp_tenv2_destroy (sp_tenv2** p);
int sp_tenv2_init (sp_data* sp, sp_tenv2* p);
int sp_tenv2_compute (sp_data* sp, sp_tenv2* p, float* in_, float* out_);

struct sp_tenvx
{
    float atk;
    float rel;
    float hold;
    float patk;
    float prel;
    uint count;
    float a_a;
    float b_a;
    float a_r;
    float b_r;
    float y;
}

int sp_tenvx_create (sp_tenvx** p);
int sp_tenvx_destroy (sp_tenvx** p);
int sp_tenvx_init (sp_data* sp, sp_tenvx* p);
int sp_tenvx_compute (sp_data* sp, sp_tenvx* p, float* in_, float* out_);

struct sp_tgate
{
    float time;
    uint timer;
}

int sp_tgate_create (sp_tgate** p);
int sp_tgate_destroy (sp_tgate** p);
int sp_tgate_init (sp_data* sp, sp_tgate* p);
int sp_tgate_compute (sp_data* sp, sp_tgate* p, float* in_, float* out_);

struct sp_thresh
{
    int init;
    float prev;
    float thresh;
    float mode;
}

int sp_thresh_create (sp_thresh** p);
int sp_thresh_destroy (sp_thresh** p);
int sp_thresh_init (sp_data* sp, sp_thresh* p);
int sp_thresh_compute (sp_data* sp, sp_thresh* p, float* in_, float* out_);

struct sp_timer
{
    int mode;
    uint pos;
    float time;
}

int sp_timer_create (sp_timer** p);
int sp_timer_destroy (sp_timer** p);
int sp_timer_init (sp_data* sp, sp_timer* p);
int sp_timer_compute (sp_data* sp, sp_timer* p, float* in_, float* out_);

struct sp_tin
{
    FILE* fp;
    float val;
}

int sp_tin_create (sp_tin** p);
int sp_tin_destroy (sp_tin** p);
int sp_tin_init (sp_data* sp, sp_tin* p);
int sp_tin_compute (sp_data* sp, sp_tin* p, float* in_, float* out_);

struct sp_tone
{
    float hp;
    float c1;
    float c2;
    float yt1;
    float prvhp;
    float tpidsr;
}

int sp_tone_create (sp_tone** t);
int sp_tone_destroy (sp_tone** t);
int sp_tone_init (sp_data* sp, sp_tone* t);
int sp_tone_compute (sp_data* sp, sp_tone* t, float* in_, float* out_);

struct sp_trand
{
    float min;
    float max;
    float val;
}

int sp_trand_create (sp_trand** p);
int sp_trand_destroy (sp_trand** p);
int sp_trand_init (sp_data* sp, sp_trand* p);
int sp_trand_compute (sp_data* sp, sp_trand* p, float* in_, float* out_);

struct sp_tseg
{
    float beg;
    float dur;
    float end;
    uint steps;
    uint count;
    float val;
    float type;
    float slope;
    float tdivnsteps;
}

int sp_tseg_create (sp_tseg** p);
int sp_tseg_destroy (sp_tseg** p);
int sp_tseg_init (sp_data* sp, sp_tseg* p, float ibeg);
int sp_tseg_compute (sp_data* sp, sp_tseg* p, float* in_, float* out_);

struct sp_tseq
{
    sp_ftbl* ft;
    float val;
    int pos;
    int shuf;
}

int sp_tseq_create (sp_tseq** p);
int sp_tseq_destroy (sp_tseq** p);
int sp_tseq_init (sp_data* sp, sp_tseq* p, sp_ftbl* ft);
int sp_tseq_compute (sp_data* sp, sp_tseq* p, float* trig, float* val);

struct sp_vdelay
{
    float del;
    float maxdel;
    float feedback;
    float prev;
    float sr;
    sp_auxdata buf;
    int left;
}

int sp_vdelay_create (sp_vdelay** p);
int sp_vdelay_destroy (sp_vdelay** p);
int sp_vdelay_init (sp_data* sp, sp_vdelay* p, float maxdel);
int sp_vdelay_compute (sp_data* sp, sp_vdelay* p, float* in_, float* out_);
int sp_vdelay_reset (sp_data* sp, sp_vdelay* p);

struct sp_voc;

int sp_voc_create (sp_voc** voc);
int sp_voc_destroy (sp_voc** voc);
int sp_voc_init (sp_data* sp, sp_voc* voc);
int sp_voc_compute (sp_data* sp, sp_voc* voc, float* out_);
int sp_voc_tract_compute (sp_data* sp, sp_voc* voc, float* in_, float* out_);

void sp_voc_set_frequency (sp_voc* voc, float freq);
float* sp_voc_get_frequency_ptr (sp_voc* voc);

float* sp_voc_get_tract_diameters (sp_voc* voc);
float* sp_voc_get_current_tract_diameters (sp_voc* voc);
int sp_voc_get_tract_size (sp_voc* voc);
float* sp_voc_get_nose_diameters (sp_voc* voc);
int sp_voc_get_nose_size (sp_voc* voc);
void sp_voc_set_tongue_shape (
    sp_voc* voc,
    float tongue_index,
    float tongue_diameter);
void sp_voc_set_tenseness (sp_voc* voc, float breathiness);
float* sp_voc_get_tenseness_ptr (sp_voc* voc);
void sp_voc_set_velum (sp_voc* voc, float velum);
float* sp_voc_get_velum_ptr (sp_voc* voc);

void sp_voc_set_diameters (
    sp_voc* voc,
    int blade_start,
    int lip_start,
    int tip_start,
    float tongue_index,
    float tongue_diameter,
    float* diameters);

int sp_voc_get_counter (sp_voc* voc);

struct sp_vocoder
{
    void* faust;
    int argpos;
    float*[3] args;
    float* atk;
    float* rel;
    float* bwratio;
}

int sp_vocoder_create (sp_vocoder** p);
int sp_vocoder_destroy (sp_vocoder** p);
int sp_vocoder_init (sp_data* sp, sp_vocoder* p);
int sp_vocoder_compute (sp_data* sp, sp_vocoder* p, float* source, float* excite, float* out_);

struct sp_waveset
{
    float rep;
    float len;
    sp_auxdata auxch;
    int length;
    int cnt;
    int start;
    int current;
    int direction;
    int end;
    float lastsamp;
    int noinsert;
}

int sp_waveset_create (sp_waveset** p);
int sp_waveset_destroy (sp_waveset** p);
int sp_waveset_init (sp_data* sp, sp_waveset* p, float ilen);
int sp_waveset_compute (sp_data* sp, sp_waveset* p, float* in_, float* out_);
struct sp_wavin;
int sp_wavin_create (sp_wavin** p);
int sp_wavin_destroy (sp_wavin** p);
int sp_wavin_init (sp_data* sp, sp_wavin* p, const(char)* filename);
int sp_wavin_compute (sp_data* sp, sp_wavin* p, float* in_, float* out_);
struct sp_wavout;
int sp_wavout_create (sp_wavout** p);
int sp_wavout_destroy (sp_wavout** p);
int sp_wavout_init (sp_data* sp, sp_wavout* p, const(char)* filename);
int sp_wavout_compute (sp_data* sp, sp_wavout* p, float* in_, float* out_);

struct sp_wpkorg35
{
    /* LPF1 */
    float lpf1_a;
    float lpf1_z;

    /* LPF2 */
    float lpf2_a;
    float lpf2_b;
    float lpf2_z;

    /* HPF */
    float hpf_a;
    float hpf_b;
    float hpf_z;

    float alpha;

    float cutoff;
    float res;
    float saturation;

    float pcutoff;
    float pres;

    uint nonlinear;
}

int sp_wpkorg35_create (sp_wpkorg35** p);
int sp_wpkorg35_destroy (sp_wpkorg35** p);
int sp_wpkorg35_init (sp_data* sp, sp_wpkorg35* p);
int sp_wpkorg35_compute (sp_data* sp, sp_wpkorg35* p, float* in_, float* out_);

struct sp_zitarev
{
    void* faust;
    int argpos;
    float*[11] args;
    float* in_delay;
    float* lf_x;
    float* rt60_low;
    float* rt60_mid;
    float* hf_damping;
    float* eq1_freq;
    float* eq1_level;
    float* eq2_freq;
    float* eq2_level;
    float* mix;
    float* level;
}

int sp_zitarev_create (sp_zitarev** p);
int sp_zitarev_destroy (sp_zitarev** p);
int sp_zitarev_init (sp_data* sp, sp_zitarev* p);
int sp_zitarev_compute (sp_data* sp, sp_zitarev* p, float* in1, float* in2, float* out1, float* out2);

struct sp_diskin;
int sp_diskin_create (sp_diskin** p);
int sp_diskin_destroy (sp_diskin** p);
int sp_diskin_init (sp_data* sp, sp_diskin* p, const(char)* filename);
int sp_diskin_compute (sp_data* sp, sp_diskin* p, float* in_, float* out_);

alias fftw_real = double;
enum rfftw_plan = fftw_plan;

struct FFTFREQS
{
    int size;
    float* s;
    float* c;
}

struct FFTwrapper
{
    int fftsize;

    kiss_fftr_cfg fft;
    kiss_fftr_cfg ifft;
    kiss_fft_cpx* tmp1;
    kiss_fft_cpx* tmp2;
}

void FFTwrapper_create (FFTwrapper** fw, int fftsize);
void FFTwrapper_destroy (FFTwrapper** fw);

void newFFTFREQS (FFTFREQS* f, int size);
void deleteFFTFREQS (FFTFREQS* f);

void smps2freqs (FFTwrapper* ft, float* smps, FFTFREQS* freqs);
void freqs2smps (FFTwrapper* ft, FFTFREQS* freqs, float* smps);

struct sp_padsynth
{
    float cps;
    float bw;
    sp_ftbl* amps;
}

int sp_gen_padsynth (sp_data* sp, sp_ftbl* ps, sp_ftbl* amps, float f, float bw);

float sp_padsynth_profile (float fi, float bwi);

int sp_padsynth_ifft (int N, float* freq_amp, float* freq_phase, float* smp);

int sp_padsynth_normalize (int N, float* smp);
int spa_open (sp_data* sp, sp_audio* spa, const(char)* name, int mode);
size_t spa_write_buf (sp_data* sp, sp_audio* spa, float* buf, uint size);
size_t spa_read_buf (sp_data* sp, sp_audio* spa, float* buf, uint size);
int spa_close (sp_audio* spa);
