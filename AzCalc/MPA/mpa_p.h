/*		mpa_p.h		*/
#ifdef		_MPA

/*	m_set.c		*/
MPA m_set(double a);
MPA m_set_a(char *s);
MPA m_set_l(long n);
MPA m_int(MPA a);
MPA m_frac(MPA a);
MPA m_roundUp(MPA a, int n);
MPA m_round45(MPA a, int n);
MPA m_round45Plus(MPA a, int n);
MPA m_round55(MPA a, int n);
MPA m_round56(MPA a, int n);
MPA m_roundDown(MPA a, int n);
MPA m_roundCut(MPA a, int n);

/*	m_zero.c	*/
int m_z_chk(MPA *a);

/*	m_cmp.c		*/
int m_cmp(MPA a, MPA b);
int m_cmp_a(MPA a, MPA b);
int m_cmp_s(MPA a, double b);
int m_acc(MPA a, MPA b);

/*	m_add.c		*/
MPA m_add(MPA a, MPA b);
MPA m_sub(MPA a, MPA b);
MPA m_add_a(MPA a, MPA b);
MPA m_sub_a(MPA a, MPA b);
int m_prs(MPA a, MPA *b);
void m_add1(MPA *a, MPA b);
void m_sub1(MPA *a, MPA b);
void m_add1_a(MPA *a, MPA b);
void m_sub1_a(MPA *a, MPA b);
MPA m_add_ss(int m, MPA a, MPA b);
MPA m_sub_ss(int m, MPA a, MPA b);
void m_adj(MPA *a, int n);

/*	m_mul.c		*/
MPA m_mul(MPA a, MPA b);
MPA m_div(MPA a, MPA b);
MPA m_mul_s(MPA a, int x);
MPA m_div_s(MPA a, int x);
void m_mul1(MPA *a, MPA b);
void m_div1(MPA *a, MPA b);
void m_mul1_s(MPA *a, int x);
void m_div1_s(MPA *a, int x);
int m_mul_ss(int m, MPA a, UINT x, MPA *b);
int m_div_ss(int m, MPA a, UINT x, MPA *b);
MPA m_inv(MPA b);
MPA m_pwr_s(MPA a, long x);
MPA m_sqr(MPA a);
MPA m_sqrt(MPA a);
MPA m_idiv(MPA a, MPA b, MPA *r);

/*	m_print.c	*/
void m_string(char *rs, MPA a);   // rs[256]:結果文字列を出力する
void m_print(char *s, MPA a, int _short);
void m_printe(char *s, MPA a, int _short);
void m_prt_b(char *s, MPA a, int _short);
void m_prt_m(char *s, MPA a, int _short);

/*	m_iset.c	*/
double m_iset(MPA a);
long m_iset_s(MPA a);

/*	m_exp.c		*/
MPA m_exp(MPA x);
MPA m_log(MPA x);
MPA m_log10(MPA x);
MPA m_x_y(MPA x, MPA y);
MPA m_10(MPA x);
MPA m_x1n(MPA x, long n);
MPA m_hcos(MPA x);
MPA m_hsin(MPA x);
MPA m_htan(MPA x);
MPA m_ahsin(MPA x);
MPA m_ahcos(MPA x);
MPA m_ahtan(MPA x);

/*	m_tri.c		*/
MPA m_sin(MPA x);
MPA m_cos(MPA x);
MPA m_2pi(MPA t1);
MPA m_tan(MPA x);
MPA m_asin(MPA x);
MPA m_acos(MPA x);
MPA m_atan(MPA x);

/*	m_gcd.c		*/
MPA m_gcd(MPA a, MPA b);
MPA m_lcm(MPA a, MPA b);
MPA m_kaijo(UINT n);
MPA m_bino(UINT m, UINT n);

/*	m_rand.c	*/
MPA m_rand(void);
void m_srand(long seed);

/*	m_mak_v.c	*/
MPA e(void);
MPA pi(void);
MPA ln2(void);
MPA ln625(void);
MPA ln75(void);

#endif
