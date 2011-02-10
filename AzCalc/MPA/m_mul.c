/*		m_mul.c		MPA * MPA --> MPA	*/
#include "mpa.h"

MPA m_mul(MPA a, MPA b)
{
	MPA c;
	int i, j;
	UINT x[NMPA2];
	UINT *p, *q, *r, *xp;
	ULONG u;
	long exp;

	if(a.zero || b.zero)	return _M0;
	for(i = 0; i < NMPA2; i++)	x[i] = 0;
	for(i = NMPA, xp = x + NMPA2 - 1, p = b.num + i; i >= 0; i--, xp--, p--)
	{
		if(*p)
		{
			u = 0;
			for(j = NMPA, q = a.num + j, r = xp; j >= 0; j--)
			{
				u += (ULONG)(*q--) * (ULONG)*p + *r;
				*r-- = (UINT)u & RADIX1;
				u >>= RADIXBITS;
			}
			while(u)
			{
				u += *r;
				*r-- = (UINT)u & RADIX1;
				u >>= RADIXBITS;
			}
		}
	}
	c.zero = 0;
	c.sign = (a.sign == b.sign)? 1: 0;
	c.exp = a.exp + b.exp + 1;
	for(i = 0, xp = x; i < NMPA2; i++, xp++)
	{
		if(*xp)	break;
		c.exp--;
	}
	if(c.exp > MAXEXP)
	{
		fprintf(stderr, "Error : Overflow  in m_mul()\n");
		return _MMAX;
	}
	if(c.exp < MINEXP)
	{
		fprintf(stderr, "Error : Underflow  in m_mul()\n");
		return _M0;
	}
	for(j = 0, p = c.num; (j <= NMPA) && (i < NMPA2); i++, j++)
		*p++ = *xp++;
	if(j <= NMPA)	for(; j <= NMPA; j++)	*p++ = 0;
	else if(*xp >= RADIX_2)
		for(i = NMPA, p = c.num + i; ++*p & RADIX; i--)	*p-- &= RADIX1;
	return c;
}

/*		m_div		MPA / MPA --> MPA	*/

MPA m_div(MPA a, MPA b)
{
	MPA c, t;
	int b0, bcom, cmp, d, i;
	UINT *p;
	ULONG a0;

	if(a.zero)	return _M0;
	if(b.zero)
	{
		fprintf(stderr, "Error : Divide by 0  in m_div()\n");
		return _MMAX;
	}
	c.zero = 0;
	c.sign = (a.sign == b.sign)? 1: 0;
	a.sign = b.sign = 1;
	if((b.num[0] << 1) & RADIX)	bcom = 1;
	else
	{
		bcom = RADIX / (b.num[0] + 1);
		m_mul1_s(&b, bcom);
	}
	c.exp = a.exp - b.exp;
	a.exp = b.exp = 0;
	if(m_cmp_a(a, b) < 0)
	{
		c.exp--;
		a.exp++;
	}
	i = 0;
	p = c.num;
	b0 = b.num[0] + 1;
	while(1)
	{
		a0 = a.num[0];
		if(a0 > b0)	d = a0 / b0;
		else
		{
			a0 = a0 * RADIX + a.num[1];
			d = a0 / b0;
			if(d < 1)	d = 1;
		}
		while(1)
		{
			t = m_sub(a, m_mul_s(b, d));
			cmp = m_cmp_a(t, b);
			if(cmp < 0)	break;
			d++;
			if(cmp == 0)	break;
		}
		if(i > NMPA)
		{
			if(d >= RADIX_2)
				for(i = NMPA, p = c.num + i; ++*p & RADIX; i--)
					*p-- &= RADIX1;
			break;
		}
		*p++ = d;
		i++;
		if(cmp == 0)
		{
			for(; i <= NMPA; i++)	*p++ = 0;
			break;
		}
		a = t;
		a.exp++;
		if(m_cmp_a(a, b) < 0)
		{
			*p++ = 0;
			i++;
			if(i > NMPA)	break;
			a.exp++;
		}
	}
	if(bcom != 1)	return m_mul_s(c, bcom);
	return c;
}

/*		m_mul_s		MPA * int --> MPA	*/

MPA m_mul_s(MPA a, int x)
{
	MPA b;
	int i;
	UINT *p, *q;
	ULONG t, xl;

	if(a.zero || x == 0)	return _M0;
	b.zero = 0;
	b.sign = (x > 0)? a.sign: 1 - a.sign;
	b.exp = a.exp;
	xl= (x > 0)? (ULONG)x: (ULONG)(-x);
	t = 0;
	for(i = NMPA, p = a.num + i, q = b.num + i; i >= 0; i--)
	{
		t += (ULONG)*p-- * xl;
		*q-- = (UINT)t & RADIX1;
		t >>= RADIXBITS;
	}
	while(t)
	{
		if(a.exp == RADIX1)
		{
			fprintf(stderr, "Error : Overflow  in m_mul_s()\n");
			return _MMAX;
		}
		for(i = NMPA, p = b.num + i, q = p - 1; i > 0; i--)	*p-- = *q--;
		*p = (UINT)t & RADIX1;
		t >>= RADIXBITS;
		b.exp++;
	}
	return b;
}

/*		m_div_s			MPA / int --> MPA	*/

MPA m_div_s(MPA a, int x)
{
	MPA b;
	int i, n;
	UINT *p, *q;
	ULONG u;

	if(x == 0)
	{
		fprintf(stderr, "Error : Divide by 0  in m_div_s()\n");
		return _MMAX;
	}
	if(a.zero)	return _M0;
	b.zero = 0;
	b.sign = (x > 0)? a.sign: 1 - a.sign;
	if(x < 0)	x = - x;
	b.exp = a.exp;
	if(a.num[0] < x)
	{
		u = a.num[0];
		n = 1;
		b.exp--;
	}
	else
	{
		u = 0;
		n = 0;
	}
	for(i = n, p = b.num, q = a.num + n; i <= NMPA; i++)
	{
		u = (u << RADIXBITS) + *q++;
		*p++ = u / x;
		u %= x;
	}
	if(n)
	{
		*p = (u << RADIXBITS) / x;
		u %= x;
	}
	if(2 * u >= x)
		for (i = NMPA, q= b.num + i; ++*q & RADIX; i--)	*q-- &= RADIX1;
	return b;
}

/*		m_mul1		MPA *= MPA	*/

void m_mul1(MPA *a, MPA b)
{
	int i, j;
	UINT x[NMPA2];
	UINT *p, *q, *r, *xp;
	ULONG u;
	long exp;

	if(a->zero)	return;
	if(b.zero)
	{
		*a = _M0;
		return;
	}
	for(i = 0; i < NMPA2; i++)	x[i] = 0;
	for(i = NMPA, xp = x + NMPA2 - 1, p = b.num + i; i >= 0; i--, xp--, p--)
	{
		if(*p)
		{
			u = 0;
			for(j = NMPA, q = a->num + j, r = xp; j >= 0; j--)
			{
				u += (ULONG)(*q--) * (ULONG)*p + *r;
				*r-- = (UINT)u & RADIX1;
				u >>= RADIXBITS;
			}
			while(u)
			{
				u += *r;
				*r-- = (UINT)u & RADIX1;
				u >>= RADIXBITS;
			}
		}
	}
	a->sign = (a->sign == b.sign)? 1: 0;
	a->exp += ++b.exp;
	for(i = 0, xp = x; i < NMPA2; i++, xp++)
	{
		if(*xp)	break;
		a->exp--;
	}
	if(a->exp > MAXEXP)
	{
		fprintf(stderr, "Error : Overflow  in m_mul1()\n");
		*a = _MMAX;
		return;
	}
	if(a->exp < MINEXP)
	{
		fprintf(stderr, "Error : Underflow  in m_mul1()\n");
		*a = _M0;
		return;
	}
	for(j = 0, p = a->num; (j <= NMPA) && (i < NMPA2); i++, j++)
		*p++ = *xp++;
	if(j <= NMPA)	for(; j <= NMPA; j++)	*p++ = 0;
	else if(*xp >= RADIX_2)
		for(i = NMPA, p = a->num + i; ++*p & RADIX; i--)	*p-- &= RADIX1;
	return;
}

/*		m_div1		MPA /= MPA	*/

void m_div1(MPA *a, MPA b)
{
	int sflag;

	if(a->zero)	return;
	if(b.zero)
	{
		sflag = a->sign;
		fprintf(stderr, "Error : Divide by 0  in m_div1()\n");
		*a = _MMAX;
		a->sign = sflag;
		return;
	}
	*a = m_div(*a, b);
	return;
}

/*		m_mul1_s		MPA *= int */

void m_mul1_s(MPA *a, int x)
{
	int i;
	UINT *p, *q;
	ULONG t, xl;

	if(a->zero)	return;
	if(x == 0)
	{
		*a = _M0;
		return;
	}
	if(x < 0)
	{
		a->sign = 1 - a->sign;
		x = - x;
	}
	xl= (ULONG)x;
	t = 0;
	for(i = NMPA, p = a->num + i; i >= 0; i--)
	{
		t += (ULONG)*p * xl;
		*p-- = (UINT)t & RADIX1;
		t >>= RADIXBITS;
	}
	while(t)
	{
		if(a->exp == MAXEXP)
		{
			fprintf(stderr, "Error : Overflow  in m_mul1_s()\n");
			*a = _MMAX;
			return;
		}
		for(i = NMPA, p = a->num + i, q = p - 1; i > 0; i--)	*p-- = *q--;
		*p = (UINT)t & RADIX1;
		t >>= RADIXBITS;
		a->exp++;
	}
	return;
}

/*		m_div1_s		MPA /= int	*/

void m_div1_s(MPA *a, int x)
{
	int i, n;
	UINT *p, *q;
	ULONG u;

	if(x == 0)
	{
		fprintf(stderr, "Error : Divide by 0  in m_div1_s()\n");
		*a = _MMAX;
		return;
	}
	if(a->zero)	return;
	if(x < 0){
		a->sign = 1 - a->sign;
		x = - x;
	}
	if(a->num[0] < x)
	{
		u = a->num[0];
		n = 1;
		a->exp--;
	}
	else
	{
		u = 0;
		n = 0;
	}
	for(i = n, p = a->num, q = p + n; i <= NMPA; i++)
	{
		u = (u << RADIXBITS) + *q++;
		*p++ = u / x;
		u %= x;
	}
	if(n)
	{
		*p = (u << RADIXBITS) / x;
		u %= x;
	}
	if(2 * u >= x)
		for (i = NMPA, q= a->num + i; ++*q & RADIX; i--)	*q-- &= RADIX1;
	return;
}

/*		m_mul_ss		MPA * int -> MPA  for a.num[m...NMPA]	*/

int m_mul_ss(int m, MPA a, UINT x, MPA *b)
{
	int i;
	UINT *p;
	ULONG t, xl;

	if(a.zero || x == 0)
	{
		*b = _M0;
		return NMPA1;
	}
	*b = a;
	xl = (ULONG)x;
	t = 0;
	for(i = NMPA, p = b->num + i; i >= m; i--)
	{
		t += (ULONG)*p * xl;
		*p++ = (UINT)t & RADIX1;
		t >>= RADIXBITS;
	}
	while(t)
	{
		t += (ULONG)*p;
		*p++ = (UINT)t & RADIX1;
		t >>= RADIXBITS;
		m--;
	}
	return m;
}

/*		m_div_ss		MPA / int -> MPA  for a.num[m...NMPA]	*/

int m_div_ss(int m, MPA a, UINT x, MPA *b)
{
	int i;
	UINT *p;
	ULONG t;

	if(a.zero)
	{
		for(i = m, p = b->num + m; i <= NMPA; i++)	*p++ = 0;
		return NMPA1;
	}
	*b = a;
	t = 0;
	for(i = m, p = b->num + m; i <= NMPA; i++)
	{
		t = (t << RADIXBITS) + *p;
		*p++ = t / x;
		t %= x;
	}
	if(2 * t >= x)
		for(i = NMPA, p = b->num + i; ++*p & RADIX; i--)	*p-- &= RADIX1;
	for(i = m, p = b->num + i; i <= NMPA; i++)	if(*p++)	break;
	return i;
}

/*		m_inv		1 / MPA --> MPA		*/

MPA m_inv(MPA b)
{
	if(b.zero)
	{
		fprintf(stderr, "Error : Divide by 0  in m_inv()\n");
		return _MMAX;
	}
	return m_div(_M1, b);
}

/*		m_pwr_s			MPA ^ int --> MPA	*/

MPA  m_pwr_s(MPA a, long x)
{
	MPA b;
	int flag = 0;

	b = m_set_l(1L);
	if(x == 0L)	return b;
	if(x < 0L)
	{
		flag = 1;
		x = - x;
	}
	if(x % 2 == 1)	b = a;
	x /= 2;
	while(x > 0)
	{
		a = m_sqr(a);
		if(x % 2 == 1)	m_mul1(&b, a);
		x /= 2;
	}
	if(flag)	return m_inv(b);
	return b;
}

/*		m_sqr		MPA ^ 2 --> MPA		*/

MPA m_sqr(MPA a)
{
	MPA b;
	int i, j;
	UINT x[NMPA2];
	UINT *p, *q, *r, *xp;
	ULONG u, pl;
	long exp;

	if(a.zero)	return _M0;
	for(i = 0, xp = x; i < NMPA2; i++)	*xp++ = 0;
	for(i = NMPA, xp = x + NMPA2 - 1, p = a.num + i; i >= 0; i--, xp -= 2, p--)
	{
		if(*p)
		{
			pl = (double)*p;
			r = xp;
			u = pl * pl + *r;
			*r-- = (UINT)u & RADIX1;
			u >>= RADIXBITS;
			pl *= 2;
			for(j = i - 1, q = p - 1; j >= 0; j--)
			{
				u += (ULONG)(*q--) * pl + *r;
				*r-- = (UINT)u & RADIX1;
				u >>= RADIXBITS;
			}
			while(u)
			{
				u += *r;
				*r-- = (UINT)u & RADIX1;
				u >>= RADIXBITS;
			}
		}
	}
	b.zero = 0;
	b.sign = 1;
	b.exp = a.exp * 2 + 1;
	for(i = 0, xp = x; i < NMPA2; i++, xp++)
	{
		if(*xp)	break;
		b.exp--;
	}
	if(b.exp > MAXEXP)
	{
		fprintf(stderr, "Error : Overflow  in m_sqr()\n");
		return _MMAX;
	}
	if(b.exp < MINEXP)
	{
		fprintf(stderr, "Error : Underflow  in m_sqr()\n");
		return _M0;
	}
	for(j = 0, p = b.num; (j <= NMPA) && (i < NMPA2); i++, j++)	*p++ = *xp++;
	if(j <= NMPA)	for(; j <= NMPA; j++)	*p++ = 0;
	else if(*xp >= RADIX_2)
		for(i = NMPA, p = b.num + i; ++*p & RADIX; i--)	*p-- &= RADIX1;
	return b;
}

/*		m_sqrt			MPA ^ 1/2 --> MPA	*/

MPA m_sqrt(MPA a)
{
	MPA b, s;

	if(a.zero)	return _M0;
	if(a.sign == 0)
	{
		fprintf(stderr, "Error : Illegal parameter  in m_sqrt()\n");
		return _M0;
	}
	s = _M1;
	b = a;
	while(m_cmp(s, b) < 0)
	{
		m_mul1_s(&s, 2);
		m_div1_s(&b, 2);
	}
	do
	{
		b = s;
		s = m_div_s(m_add(m_div(a, s), s), 2);
	} while(m_cmp(s, b) < 0);
	return b;
}

/*		m_idiv		integer (MPA / MPA) --> MPA		r : residue		*/

MPA m_idiv(MPA a, MPA b, MPA *r)
{
	MPA c;
	int a0, b0, cmp, d, i;
	UINT *p;

	if(a.zero || m_cmp_a(a, b) < 0)
	{
		*r = a;
		return _M0;
	}
	if(b.zero)
	{
		fprintf(stderr, "Error : Divide by 0  in m_idiv()\n");
		*r = _M0;
		return _MMAX;
	}
	c = m_int(m_div(a, b));
	while(1)
	{
		*r = m_sub(a, m_mul(b, c));
		cmp = m_cmp_a(*r, b);
		if(cmp < 0)	break;
		*r = _M1;
		m_add1_a(&c, *r);
		if(cmp == 0)
		{
			*r = _M0;
			break;
		}
	}
	return c;
}
