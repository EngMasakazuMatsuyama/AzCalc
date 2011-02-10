/*	m_add.c		MPA + MPA --> MPA	*/
#include "mpa.h"

MPA m_add(MPA a, MPA b)
{
	MPA c;
	int cmp;

	if(a.zero)	return b;
	else if(b.zero)	return a;
	if(a.sign == b.sign)
	{
		c = m_add_a(a, b);
		c.sign = a.sign;
	}
	else
	{
		cmp = m_cmp_a(a, b);
		if(cmp == 0)	return _M0;
		if(cmp > 0)
		{
			c = m_sub_a(a, b);
			c.sign = a.sign;
		}
		else
		{
			c = m_sub_a(b, a);
			c.sign = b.sign;
		}
	}
	return c;
}

/*		m_sub		MPA - MPA --> MPA	*/

MPA m_sub(MPA a, MPA b)
{
	MPA c;
	int cmp;

	if(a.zero)
	{
		if(b.zero)	return _M0;
		b.sign = 1 - b.sign;
		return b;
	}
	if(b.zero)	return a;
	if(a.sign != b.sign)
	{
		c = m_add_a(a, b);
		c.sign = a.sign;
		return c;
	}
	cmp = m_cmp_a(a, b);
	if(cmp == 0)	return _M0;
	if(cmp > 0)
	{
		c = m_sub_a(a, b);
		c.sign = a.sign;
		return c;
	}
	c = m_sub_a(b, a);
	c.sign = 1 - b.sign;
	return c;
}

/*		m_add_a		|MPA| + |MPA| --> MPA	*/

MPA m_add_a(MPA a, MPA b)
{
	MPA c;
	int i;
	UINT k, *p, u;

	if(a.zero)
	{
		c = b;
		c.sign = 1;
		return c;
	}
	if(b.zero)
	{
		c = a;
		c.sign = 1;
		return c;
	}
	if(m_cmp_a(a, b) < 0)
	{
		c = b;
		b = a;
		a = c;
	}
	i = m_prs(a, &b);
	if(i == -999)	return _M0;
	c.zero = 0;
	c.sign = 1;
	c.exp = a.exp;
	u = 0;
	if(i >= RADIX_2)	u = 1;
	for(i = NMPA; i >= 0; i--)
	{
		u += (a.num[i] + b.num[i]);
		c.num[i] = u & RADIX1;
		u >>= RADIXBITS;
	}
	if(u == 0)	return c;
	if(c.exp == MAXEXP)
	{
		fprintf(stderr, "Error : Overflow  in m_add_a()\n");
		return _MMAX;
	}
	k = c.num[NMPA];
	for(i = NMPA; i > 0; i--)	c.num[i] = c.num[i - 1];
	c.num[0] = u;
	c.exp++;
	if(k >= RADIX_2)
		for (i = NMPA, p = c.num + i; ++*p & RADIX; i--)	*p-- &= RADIX1;
	return c;
}

/*		m_sub_a		|MPA a| - |MPA b| --> |MPA|		|a| > |b|	*/

MPA m_sub_a(MPA a, MPA b)
{
	MPA c;
	int i;
	UINT n, *p, *q, *r, u;

	c.zero = 0;
	c.sign = 1;
	c.exp = a.exp;
	i = m_prs(a, &b);
	if(i == -999)	return a;
	u = 0;
	if(i >= RADIX_2)	u = 1;
	for(i = NMPA, p = a.num + i, q = b.num + i, r = c.num + i; i >= 0; i--)
	{
		u = (*p--) - (*q--) - u;
		*r-- = u & RADIX1;
		u = (u >> RADIXBITS) & 1;
	}
	for(n = 0, r = c.num; n <= NMPA; n++, r++)	if(*r)	break;
	if(n == 0)	return c;
	if(c.exp > MAXEXP - n)	n = MAXEXP - c.exp;
	for(i = n, p = r, r = c.num; i <= NMPA; i++)	*r++ = *p++;
	for(i = 0; i < n; i++)	*r++ = 0;
	c.exp -= n;
	return c;
}

/*		m_prs		MPA b.exp comform to MPA a.exp	(|a| > |b|)	*/

int m_prs(MPA a, MPA *b)
{
	int i, r;
	UINT n, *p, *q;

	if(m_cmp_a(a, *b) < 0)
	{
		fprintf(stderr, "Error : |a| < |b|  in m_prs()\n");
		return -999;
	}
	n = a.exp - b->exp;
	if(n == 0)	return -1;
	if(n > NMPA)
	{
		*b = _M0;
		return 0;
	}
	r = b->num[NMPA - n + 1];
	b->exp = a.exp;
	for(i = NMPA, p = b->num + i, q = p - n; i >= n; i--)	*p-- = *q--;
	for(; i >= 0; i--)	*p-- = 0;
	return r;
}

/*		m_add1		MPA += MPA	*/

void m_add1(MPA *a, MPA b)
{
	int cmp;

	if(a->zero)
	{
		*a = b;
		return;
	}
	if(b.zero)	return;
	if(a->sign == b.sign)
	{
		m_add1_a(a, b);
		return;
	}
	cmp = m_cmp_a(*a, b);
	if(cmp == 0)
	{
		*a = _M0;
		return;
	}
	if(cmp > 0)
	{
		m_sub1_a(a, b);
		return;
	}
	m_sub1_a(&b, *a);
	*a = b;
	return;
}

/*		m_sub1		MPA -= MPA	*/

void m_sub1(MPA *a, MPA b)
{
	int cmp;

	if(b.zero)	return;
	if(a->zero)
	{
		*a = b;
		a->sign = 1 - a->sign;
	}
	if(a->sign != b.sign)
	{
		m_add1_a(a, b);
		return;
	}
	cmp = m_cmp_a(*a, b);
	if(cmp == 0)
	{
		*a = _M0;
		return;
	}
	if(cmp > 0)
	{
		m_sub1_a(a, b);
		return;
	}
	m_sub1_a(&b, *a);
	*a = b;
	a->sign = 1 - b.sign;
	return;
}

/*		m_add1_a.c		|MPA| += |MPA|	*/

void m_add1_a(MPA *a, MPA b)
{
	int cmp, i, sign;
	UINT k, *p, *q, u;
	MPA t;

	if(b.zero)	return;
	sign = a->sign;
	if(a->zero)
	{
		*a = b;
		a->sign = sign;
		return;
	}
	cmp = m_cmp_a(*a, b);
	if(cmp < 0)
	{
		t = *a;
		*a = b;
		b = t;
		a->sign = sign;
	}
	i = m_prs(*a, &b);
	if(i == -999)
	{
		*a = _M0;
		return;
	}
	u = 0;
	if(i >= RADIX_2)	u = 1;
	for(i = NMPA, p = a->num + i, q = b.num + i; i >= 0; i--)
	{
		u += (*p + *q--);
		*p-- = u & RADIX1;
		u >>= RADIXBITS;
	}
	if(u == 0)
	{
		a->sign = sign;
		return;
	}
	if(a->exp == MAXEXP)
	{
		fprintf(stderr, "Error : Overflow  in m_add1_a()\n");
		*a = _MMAX;
		return;
	}
	k = a->num[NMPA];
	for(i = NMPA, p = a->num + i, q = p - 1; i > 0; i--)	*p-- = *q--;
	*p = u;
	a->exp++;
	if(k >= RADIX_2)
		for (i = NMPA, p = a->num + NMPA; ++*p & RADIX ; i--)	*p-- &= RADIX1;
	a->sign = sign;
	return;
}

/*		m_sub1_a		|MPA a| -= |MPA b|	*/

void m_sub1_a(MPA *a, MPA b)
{
	int i, sign;
	UINT n, *p, *q, u;

	sign = a->sign;
	i = m_prs(*a, &b);
	if(i == -999)	return;
	u = 0;
	if(i >= RADIX_2)	u = 1;
	for(i = NMPA, p = a->num + i, q = b.num + i; i >= 0; i--)
	{
		u = *p - (*q--) - u;
		*p-- = u & RADIX1;
		u = (u >> RADIXBITS) & 1;
	}
	for(n = 0, p = a->num; n <= NMPA; n++, p++)	if(*p)	break;
	if(n == 0)
	{
		a->sign = sign;
		return;
	}
	if(a->exp > MAXEXP - n)	n = MAXEXP - a->exp;
	for(i = n, q = a->num; i <= NMPA; i++)	*q++ = *p++;
	for(i = 0; i < n; i++)	*q++ = 0;
	a->exp -= n;
	a->sign = sign;
	return;
}

/*		m_add_ss		MPA + MPA -> MPA  for b.num[m...NMPA]	*/

MPA m_add_ss(int m, MPA a, MPA b)
{
	MPA c;
	int i;
	UINT *p, *q;
	ULONG t;

	if(a.zero)	return b;
	c = a;
	t = 0;
	for(i = NMPA, p = c.num + i, q = b.num + i; i >= m; i--)
	{
		t += ((ULONG)*p + (ULONG)*q--);
		*p-- = (UINT)t & RADIX1;
		t >>= RADIXBITS;
	}
	if(t)	for( ; ++*p & RADIX; i--)	*p-- &= RADIX1;
	return c;
}

/*		m_sub_ss		MPA - MPA -> MPA  for b.num[m...NMPA]	*/

MPA m_sub_ss(int m, MPA a, MPA b)
{
	MPA c;
	int i;
	UINT *p, *q;
	ULONG t;

	c = a;
	t = 0;
	for(i = NMPA, p = c.num + i, q = b.num + i; i >= m; i--)
	{
		t = (ULONG)*p + (ULONG)*q-- - t;
		*p-- = (UINT)t & RADIX1;
		t = (t >> RADIXBITS) & 1;
	}
	if(t)
	{
		for( ; i >= 0; i--)
		{
			t = (ULONG)*p - t;
			*p-- = (UINT)t & RADIX1;
			t = (t >> RADIXBITS) & 1;
		}
	}
	return c;
}

/*		m_adj		MPA exponential adjust	*/

void m_adj(MPA *a, int n)
{
	int i, nn;
	UINT d, *p, *q;
	ULONG u;

	if(n < MINEXP || n > MAXEXP)
	{
		fprintf(stderr, "Error : Illegal parameter  in m_adj()\n");
		return;
	}
	if(n == a->exp)	return;
	if(abs(n - a->exp) > NMPA)
	{
		for(i = 0, p = a->num; i <= NMPA; i++)	*p++ = 0;
		a->exp = n;
		return;
	}
	if(n < a->exp)
	{
		nn = a->exp - n;
		for(i = 0, p = a->num; i < nn; i++)
		{
			if(*p++)
			{
				fprintf(stderr, "Error : Overflow  in m_adj()\n");
				return;
			}
		}
		for(i = nn, q = a->num; i <= NMPA; i++)	*q++ = *p++;
		for(i = 0; i < nn; i++)	*q++ = 0;
		a->exp = n;
		return;
	}
	nn = n - a->exp;
	d = a->num[NMPA - nn + 1];
	for(i = nn, q = a->num + NMPA, p = q - nn; i <= NMPA; i++)	*q-- = *p--;
	for(i = 0; i < nn; i++)	*q-- = 0;
	if(d > RADIX_2)
		for(i = NMPA, p = a->num + i; ++*p & RADIX; i--)	*p-- &= RADIX1;
	a->exp = n;
	return;
}
