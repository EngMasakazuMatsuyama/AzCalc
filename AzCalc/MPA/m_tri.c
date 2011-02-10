/*		m_tri.c			Trigonometric function	*/
#include "mpa.h"

/*	Sine function	*/

MPA m_sin(MPA x)
{
	MPA s, x2;
	int i, k, sflag;

	if(x.zero)	return _M0;
	sflag = x.sign;
	x.sign = 1;
	x = m_2pi(x);
	if(x.zero)	return _M0;
	if(m_cmp_a(x, _PI) > 0)
	{
		sflag = 1 - sflag;
		x = m_sub(_2_PI, x);
	}
	if(m_cmp_a(x, _PI_2) > 0)	x = m_sub(_PI, x);
	if(m_cmp_a(x, _PI_4) > 0)
	{
		s = m_cos(m_sub(_PI_2, x));
		s.sign = sflag;
		return s;
	}
	s = x;
	x2 = m_sqr(x);
	k = 2;
	do
	{
		if(k <= MAX_K)	x = m_div_s(m_mul(x, x2), k * (k + 1));
		else			x = m_div_s(m_div_s(m_mul(x, x2), k), k + 1);
		k += 2;
		if(k & 2)	m_add1(&s, x);
		else		m_sub1(&s, x);
	} while(s.exp - x.exp <= NMPA);
	s.sign = sflag;
	return s;
}

/*	Cosine function	*/

MPA m_cos(MPA x)
{
	MPA s, x2;
	int i, k, sflag;

	if(x.zero)	return _M1;
	sflag = 1;
	x.sign = 1;
	x = m_2pi(x);
	if(x.zero)	return _M1;
	if(m_cmp_a(x, _PI) > 0)	x = m_sub(_2_PI, x);
	if(m_cmp_a(x, _PI_2) > 0)
	{
		sflag = 0;
		x = m_sub(_PI, x);
	}
	if(m_cmp_a(x, _PI_4) > 0)
	{
		s = m_sin(m_sub(_PI_2, x));
		s.sign = sflag;
		return s;
	}
	s = _M1;
	x2 = m_sqr(x);
	x = s;
	k = 1;
	do
	{
		if(k <= MAX_K)	x = m_div_s(m_mul(x, x2), k * (k + 1));
		else			x = m_div_s(m_div_s(m_mul(x, x2), k), k + 1);
		k += 2;
		if(k & 2)	m_sub1(&s, x);
		else		m_add1(&s, x);
	} while(s.exp - x.exp < NMPA);
	s.sign = sflag;
	return s;
}

MPA m_2pi(MPA t1)
{
	int sign;

	if(t1.zero)	return t1;
	sign = t1.sign;
	t1.sign = 1;
	m_idiv(t1, _2_PI, &t1);
	if(sign == 1)	return t1;
	return m_sub(_2_PI, t1);
}

MPA m_tan(MPA x)
{
	MPA p1, q1, t, x2, y;
	int cmp, flag, k, xsign;

	y = x;
	if(x.zero)	return y;
	xsign = x.sign;
	x.sign = 1;
	t = m_idiv(x, _PI, &x);
	cmp = m_cmp(x, _PI_2);
	if(cmp == 0)
	{
		y = _MMAX;
		y.sign = xsign;
		return y;
	}
	if(cmp > 0)
	{
		m_sub1(&x, _PI);
		x.sign = 1;
	}
	flag = m_cmp(x, _PI_4);
	if(flag == 0)
	{
		y = _M1;
		y.sign = xsign;
		return y;
	}
	if(flag > 0)	x = m_sub(_PI_2, x);

	x2 = m_sqr(x);
	x2.sign = 0;
	q1 = _M1;
	p1 = _M0;
	k = 1;
	do
	{
		k += 2;
		t = m_add(m_mul_s(x, k), m_mul(p1, x2));
		p1 = x;
		x = t;
		t = m_add(m_set_l((long)k), m_mul(q1, x2));
		m_div1(&p1, t);
		q1 = m_inv(t);
		m_mul1(&x, q1);
		cmp = m_acc(y, x);
		y = x;
	} while(cmp < NMPA);
	if(flag <= 0)	return y;
	return m_inv(y);
}

/*		m_asin			arc sin(MPA) --> MPA	*/

MPA m_asin(MPA x)
{
	MPA s, t, u;
	int cmp, k, m, sflag;

	if(x.zero)	return _M0;
	sflag = x.sign;
	x.sign = 1;
	cmp = m_cmp_a(x, _M1);
	if(cmp > 0)
	{
		fprintf(stderr, "Error : Illegal parameter  in m_asin()\n");
		return _M0;
	}
	if(cmp == 0)
	{
		s = _PI_2;
		goto ret1;
	}
	cmp = m_cmp_a(x, _1_SQRT2);
	if(cmp == 0)
	{
		s = _PI_4;
		goto ret1;
	}
	else if(cmp > 0)
	{
		s = m_sub(_PI_2, m_asin(m_sqrt(m_sub(_M1, m_sqr(x)))));
		goto ret1;
	}
	s = t = x;
	x = m_sqr(x);
	k = 1;
	do
	{
		m_mul1(&t, x);
		u = m_div_s(m_div_s(m_mul_s(t, k), k + 1), k + 2);
		m_add1(&s, u);
		k += 2;
	} while(s.exp - u.exp < NMPA);
ret1:
	s.sign = sflag;
	return s;
}

/*		m_acos			arc cos(MPA) --> MPA	*/

MPA m_acos(MPA x)
{
	MPA s;

	s = m_sub(m_asin(x), _PI_2);
	s.sign = 1 - s.sign;
	return s;
}

/*		m_atan			arc tan(MPA) --> MPA	*/

MPA m_atan(MPA x)
{
	if(x.zero)	return _M0;
	return m_asin(m_div(x, m_sqrt(m_add(m_sqr(x), _M1))));
}
