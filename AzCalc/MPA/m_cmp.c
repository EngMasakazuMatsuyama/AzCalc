/*		m_cmp.c		compare MPA vs MPA	*/
#include "mpa.h"

int m_cmp(MPA a, MPA b)
{
	int mca;

	if(a.zero)
	{
		if(b.zero)	return 0;
		return (b.sign == 1)? -1: 1;
	}
	if(b.zero)	return (a.sign == 1)? 1: -1;
	if(a.sign == b.sign)
	{
		mca = m_cmp_a(a, b);
		return (a.sign == 1)? mca: -mca;
	}
	return (a.sign == 1)? 1: -1;
}

/*		m_cmp_a			compare |MPA| vs |MPA|	*/

int m_cmp_a(MPA a, MPA b)
{
	int i;
	UINT *p, *q;

	if(a.zero)	return (b.zero)? 0: -1;
	if(b.zero)	return 1;
	while(a.num[0] == 0 && a.exp != MINEXP)
	{
		for(i = 0, p = a.num, q = p + 1; i < NMPA; i++)	*p++ = *q++;
		*p = 0;
		a.exp--;
	}
	while(b.num[0] == 0 && b.exp != MINEXP)
	{
		for(i = 0, p = b.num, q = p + 1; i < NMPA; i++)	*p++ = *q++;
		*p = 0;
		b.exp--;
	}
	if(a.exp != b.exp)	return (a.exp > b.exp)? 1: -1;
	for(i = 0, p = a.num, q = b.num; i <= NMPA; i++, p++, q++)
		if(*p != *q)	return (*p > *q)? 1: -1;
	return 0;
}

/*		m_cmp_s		compare MPA vs double	*/

int m_cmp_s(MPA a, double b)
{
	char s[30];

	sprintf(s, "%25.18e", b);
	return m_cmp(a, m_set_a(s));
}

/*		m_acc		MPA : MPA compare	*/

int m_acc(MPA a, MPA b)
{
	int i;
	UINT *p, *q;

	if(a.zero != b.zero || a.sign != b.sign || a.exp != b.exp)	return 0;
	for(i = 0, p = a.num, q = b.num; i <= NMPA && *p++ == *q++; i++)
		;
	return i;
}
