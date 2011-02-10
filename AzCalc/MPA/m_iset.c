/*		m_iset.c		MPA --> double	*/
#include "mpa.h"

double m_iset(MPA a)
{
	double d;
	int i;
	UINT *p, *q;

	if(a.zero)	return 0.;
	if(a.exp > 68)
	{
		fprintf(stderr, "Warning : Overflow in m_iset()\n");
		return DBL_MAX;  //MAXDOUBLE;
	}
	if(a.exp < -68)
	{
		fprintf(stderr, "Warning : Underflow in m_iset()\n");
		return DBL_MIN;  //MINDOUBLE;
	}
	while(a.num[0] == 0)
	{
		for(i = 0, p = a.num, q = p + 1; i < NMPA; i++)	*p++ = *q++;
		*p = 0;
		a.exp--;
	}
	p = a.num;
	d = (double)*p++;
	for(i = 1; i < 7; i++)
	{
		d = d * (double)RADIX + (double)*p++;
		a.exp--;
	}
	if(*p >= RADIX_2)	d += 1.;
	while(a.exp > 0)
	{
		d *= (double)RADIX;
		a.exp--;
	}
	while(a.exp < 0)
	{
		d /= (double)RADIX;
		a.exp++;
	}
	return (a.sign == 1)? d: -d;
}

/*	 	m_iset_s		MPA --> long	*/

long m_iset_s(MPA a)
{
	int errflg, i, j;
	UINT *p, *q;
	long d, m;

	errflg = -1;
	if(a.zero || a.exp < 0)	return 0L;
	if(a.exp > NMPA)	errflg = a.sign;
	if(errflg == -1)
	{
		for(i = 0, p = a.num; i <= NMPA; i++, p++)	if(*p) break;
		if(i)
		{
			for(j = i, q = a.num; j <= NMPA; j++)	*q++ = *p++;
			for(j = 0; j < i; j++, a.exp--)	*q++ = 0;
		}
		if(a.exp >= 3 || (a.exp == 2 && a.num[0] > 2))	errflg = a.sign;
		if(errflg == -1)
		{
			for(i = 0, d = 0, p = a.num; i <= a.exp; i++)
				d = d * (long)RADIX + *p++;
			return (a.sign == 1)? d: -d;
		}
	}
	fprintf(stderr, "Error : Overflow  in m_iset_s()\n");
	if(errflg == 1)	return MAX_LONG;
	return MIN_LONG;
}
