/*		mak_vh.c		make 'mpa_v###.h' file		*/
#include "mpa.h"

/*#define		DEBUG		/* when debug, fp -> display */

void m_prt_v(char *s, MPA a, FILE *fp)
{
	int i;
	UINT *p;

	fprintf(fp, "\nstatic MPA %s = {\n\t%5d,\t\t/* sign */\n", s, a.sign);
	fprintf(fp, "\t%5d,\t\t/* exp */\n", a.exp);
	fprintf(fp, "\t%5d,\t\t/* zero */\n\t", a.zero);
	for(i = 0, p = a.num; i < NMPA; i++)
	{
		fprintf(fp, "%5d,", *p++);
		if(i % 10 == 9)	fprintf(fp, "\n\t");
	}
	fprintf(fp, "%5d};\n", *p);
	return;
}

int main(void)
{
	MPA a, b, c, d;
	char s[30];
	double dn, w;
	long n;
	int i, k; 
	FILE *fp;

#ifndef DEBUG
	sprintf(s, "mpa_v%d.h\0", NMPA);
	fp = fopen(s, "a+t");
	if(fp == NULL)
	{
		fprintf(stderr, "Error : File(%s) can't open in text mode.\n", s);
		exit(-1);
	}
#else
	fp = stdout;
#endif
	fprintf(fp, "/*\t\t%s\t\t< values of mpa >\t\t*/\n", s);

	fprintf(fp, "#ifndef\t\t_MPA_VF\n\n#define\t\t_MPA_VF\n");
	d = pi();
	m_prt_v("_E", e(), fp);
	m_prt_v("_PI", d, fp);
	m_prt_v("_2_PI", m_mul_s(d, 2), fp);
	m_prt_v("_PI_2", m_div_s(d, 2), fp);
	m_prt_v("_PI_4", m_div_s(d, 4), fp);
	m_prt_v("_SQRT3", m_sqrt(m_set_l(3L)), fp);
	b = m_sqrt(m_set_l(2L));
	m_prt_v("_SQRT2", b, fp);
	m_prt_v("_1_SQRT2", m_inv(b), fp);
	b = ln2();
	m_prt_v("_LN2", b, fp);
	a = m_add(ln625(), m_mul_s(b, 4));
	m_prt_v("_LN10", a, fp);
	m_prt_v("_LNRADIX", m_mul_s(b, RADIXBITS), fp);
	m_prt_v("_LOG10_2", m_div(b, a), fp);
	m_prt_v("_LOG10_3", m_div(m_add(ln75(), m_mul_s(b, 2)), a), fp);
	c = d;
	b = m_sqr(d);
	k = 2;
	do
	{
		d = m_div_s(m_div_s(m_mul(d, b), k), k + 1);
		a = m_div_s(d, k + 1);
		k += 2;
		if(k & 2)	m_add1(&c, a);
		else		m_sub1(&c, a);
	} while(c.exp - a.exp < NMPA);
	m_prt_v("_G", c, fp);

	a.zero = 0;
	a.sign = 1;
	a.exp = MAXEXP;
	for(i = 0; i <= NMPA; i++)	a.num[i] = RADIX1;

	m_prt_v("_MAX_M_EXP", m_log(a), fp);
	m_prt_v("_MAX_M_10", m_log10(a), fp);
	m_prt_v("_MMAX", a, fp);

	a.zero = 1;
	a.sign = 1;
	a.exp = 0;
	for(i = 0; i <= NMPA; i++)	a.num[i] = 0;
	m_prt_v("_M0", a, fp);

	a.zero = 0;
	a.num[0] = 1;
	m_prt_v("_M1", a, fp);

	w = m_iset(_MAX_M_EXP) - 0.5 * log(2. * M_PI);
	n = 1;
	while(1)
	{
		dn = n + 1;
		if(w < (dn - 0.5) *log(dn) - dn)	break;
		n++;
	}
	fprintf(fp, "\nstatic UINT _MAX_KAIJO = %ld;\n", --n);

	fprintf(fp, "\n#endif\n");

	fclose(fp);
	return 1;
}
