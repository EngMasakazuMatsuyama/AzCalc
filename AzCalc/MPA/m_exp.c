/*		m_exp.c		exp(MPA) --> MPA	*/
#include "mpa.h"

MPA m_exp(MPA x)
{
	MPA a, s, t;
	int cmp, k, xflag;

	if(x.zero)	return _M1;
	xflag = x.sign;
	x.sign = 1;
	cmp = m_cmp_a(x, _MAX_M_EXP);
	if(cmp >= 0)
	{
		if(xflag == 0)
		{
			fprintf(stderr, "Warning : underflow in m_exp()\n");
			return _M0;
		}
		fprintf(stderr, "Warning : overflow in m_exp()\n");
		return _MMAX;
	}
	a = m_int(x);
	m_sub1(&x, a);
	s = m_pwr_s(_E, m_iset_s(a));
	if(x.zero)	return s;
	a = m_add(_M1, x);
	t = x;
	k = 2;
	do
	{
		m_mul1(&t, x);
		m_div1_s(&t, k++);
		m_add1(&a, t);
	} while(a.exp - t.exp < NMPA);
	m_mul1(&s, a);
	if(xflag == 0)	s = m_inv(s);
	return s;
}

/*	m_log		log(MPA) --> MPA	*/

MPA m_log(MPA x)
{
	MPA s, t, u;
	int k, m, n, w;
	UINT *p, *q, x0;
	ULONG a;

	if(x.zero || x.sign == 0)
	{
		fprintf(stderr, "Error : Illegal parameter  in m_log()\n");
		s = _MMAX;
		s.sign = 0;
		return s;
	}
	s = _M0;
	t = _M1;
	if(m_cmp_a(x, t) == 0)	return s;
	x0 = x.num[0];
	for(m = 0, w = 1; m < RADIXBITS; m++, w *= 2)
		if((x0 <<= 1) & RADIX)	break;
	m_mul1_s(&x, w);
	n = x.exp + 1;
	x.exp = -1;
	a = 0;
	for(k = NMPA, p = x.num + k, q = t.num + k; k >= 0; k--)
	{
		a = - (*p-- + a);
		*q-- = (UINT)a & RADIX1;
		a = (a >>= RADIXBITS) & 1;
	}
	t.zero = 0;
	t.sign = 0;
	t.exp = -1;
	x0 = x.num[NMPA];
	for(k = NMPA, p = x.num + k, q = p - 1; k > 0; k--)	*p-- = *q--;
	*p = 1;
	x.zero = x.exp = 0;
	x.sign = 1;
	x = m_div(t, x);
	t = m_mul_s(x, 2);
	x = m_sqr(x);
	s = t;
	k = 3;
	do
	{
		m_mul1(&t, x);
		u = m_div_s(t, k);
		m_add1(&s, u);
		k += 2;
	} while(s.exp - u.exp <= NMPA);
	if(m)	m_sub1(&s, t = m_mul_s(_LN2, m));
	if(n)
	{
		t = m_mul_s(m_mul_s(_LN2, RADIXBITS), n);
		m_add1(&s, t);
	}
	return s;
}

/*	m_log10		log10(MPA) --> MPA	*/

MPA m_log10(MPA x)
{
	MPA s;

	if(x.zero || x.sign == 0)
	{
		fprintf(stderr, "Error : Illegal parameter  in m_log10()\n");
		s = _MMAX;
		s.sign = 0;
		return s;
	}
	return m_div(m_log(x), _LN10);
}

/*		m_x_y			MPA ^ MPA --> MPA	*/

MPA m_x_y(MPA x, MPA y)
{
	if(x.zero || x.sign == 0)
	{
		fprintf(stderr, "Error : Illegal parameter in m_x_y()\n");
		return _M0;
	}
	return m_exp(m_mul(y, m_log(x)));
}

/*		m_10		10 ^ MPA --> MPA	*/

MPA m_10(MPA x)
{
	int cmp;

	if(x.zero)	return _M1;
	cmp = m_cmp_a(x, _MAX_M_10);
	if(cmp >= 0)
	{
		if(x.sign == 1)
		{
			fprintf(stderr, "Warning : overflow in m_10()\n");
			return _MMAX;
		}
		fprintf(stderr, "Warning : underflow in m_10()\n");
		return _M0;
	}
	return m_exp(m_mul(x, _LN10));
}

/*		m_x1n		MPA ^ (1 / N) --> MPA	*/

MPA m_x1n(MPA x, long n)
{
	if(n == 0L)
	{
		fprintf(stderr, "Error : Illegal parameter in m_x1n()\n");
		return _M0;
	}
	if(n == 1L)	return x;
	return m_exp(m_div(m_log(x), m_set_l(n)));
}

/*	Hyporbolic Function	*/
/*		m_hcos			hcos(MPA) --> MPA	*/

MPA m_hcos(MPA x)
{
	MPA t, y;
	int k;

	y = _M1;
	if(x.zero)	return y;
	x = m_sqr(x);
	k = 2;
	t = m_div_s(x, k++);
	m_add1(&y, t);
	while(y.exp - t.exp < NMPA)
	{
		if(k <= MAX_K)
		{
			m_div1_s(&t, k * (k + 1));
			k += 2;
		}
		else
		{
			m_div1_s(&t, k++);
			m_div1_s(&t, k++);
		}
		m_mul1(&t, x);
		m_add1(&y, t);
	}
	return y;
}

/*		m_hsin			hsin(MPA) --> MPA	*/

MPA m_hsin(MPA x)
{
	MPA t, y;
	int k;

	if(x.zero)	return _M0;
	t = y = x;
	x = m_sqr(x);
	k = 2;
	while(y.exp - t.exp < NMPA)
	{
		if(k <= MAX_K)
		{
			m_div1_s(&t, k * (k + 1));
			k += 2;
		}
		else
		{
			m_div1_s(&t, k++);
			m_div1_s(&t, k++);
		}
		m_mul1(&t, x);
		m_add1(&y, t);
	}
	return y;
}

/*		m_htan			htan(MPA) --> MPA	*/

MPA m_htan(MPA x)
{
	MPA y;
	int xsign;

	if(x.zero)	return _M0;
	m_mul1_s(&x, 2);
	xsign = x.sign;
	x.sign = 0;
	y = m_exp(x);
	m_add1(&y, _M1);
	y = m_inv(y);
	m_mul1_s(&y, -2);
	m_add1(&y, _M1);
	if(xsign == 0)	y.sign = 0;
	return y;
}

/*	Inverse Hyporbolic Function	*/
/*		m_ahsin			arc hsin(MPA) --> MPA	*/

MPA m_ahsin(MPA x)
{
	MPA t, y;
	int xsign;

	if(x.zero)	return _M0;
	t = m_sqrt(m_add(m_sqr(x), _M1));
	xsign = x.sign;
	x.sign = 1;
	y = m_log(m_add(t, x));
	y.sign = xsign;
	return y;
}

/*		m_ahcos			arc hcos(MPA) --> MPA	*/

MPA m_ahcos(MPA x)
{
	int cmp;

	cmp = m_cmp(x, _M1);
	if(cmp < 0)
	{
		fprintf(stderr, "Error : Illegal parameter in m_ahcos()\n");
		return _M0;
	}
	if(cmp == 0)	return _M0;
	return m_log(m_add(m_sqrt(m_sub(m_sqr(x), _M1)), x));
}

/*		m_ahtan			arc htan(MPA) --> MPA	*/

MPA m_ahtan(MPA x)
{
	MPA c, t, y;
	int k, xsign;

	t = _M1;
	xsign = x.sign;
	x.sign = 1;
	if(m_cmp(x, t) >= 0)
	{
		fprintf(stderr, "Error : Illegal parameter in m_ahtan()\n");
		return _M0;
	}
	x.sign = xsign;
	if(m_cmp(x, m_set_a("0.176")) > 0)
		return m_div_s(m_log(m_div(m_add(t, x), m_sub(t, x))), 2);

	y = c = x;
	x = m_sqr(x);
	k = 3;
	do
	{
		m_mul1(&c, x);
		t = m_div_s(c, k);
		m_add1(&y, t);
		k += 2;
	} while(y.exp - t.exp < NMPA);
	return y;
}
