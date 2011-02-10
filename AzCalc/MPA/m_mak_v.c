/*		m_mak_v.c		make MPA constant	*/
#include "mpa.h"

/*		e		nepia's constant	*/

MPA e(void)
{
	MPA a, t;
	int m;
	UINT k;

	a = t = _M0;
	a.zero = t.zero = 0;
	a.num[0] = 2;
	a.num[1] = t.num[1] = RADIX_2;
	k = 3;
	m = 1;
	while((m = m_div_ss(m, t, k, &t)) <= NMPA)
	{
		m_add1_a(&a, t);
		if(++k == RADIX)
		{
			fprintf(stderr, "Error : Too long  in e()\n");
			break;
		}
	}
	return a;
}

/*		pi			Calculating ƒÎ	*/

MPA pi(void)
{
	MPA a, t, u;
	int i, m;
	UINT k, *p, *q;

	t = u = _M0;
	t.sign = 1;
	t.zero = u.zero = 0;
	t.num[0] = 16;
	m_div_ss(0, t, 5, &t);
	a = t;
	i = m = 0;
	k = 1;
	while(1)
	{
		if((m = m_div_ss(m, t, 25, &t)) > NMPA)	break;
		if((k += 2) >= RADIX)
		{
			fprintf(stderr, "Error : Too long  in pi()\n");
			return a;
		}
		while(i < m)	u.num[i++] = 0;
		if(m_div_ss(m, t, k, &u) > NMPA)	break;
		if(k & 2)	m_sub1(&a, u);
		else		m_add1(&a, u);
	}
	t = _M0;
	t.sign = 1;
	t.zero = 0;
	t.num[0] = 4;
	m_div_ss(0, t, 239, &t);
	m_sub1(&a, t);
	i = m = 0;
	k = 1;
	while(1)
	{
		if((m = m_div_ss(m, t, 239, &t)) > NMPA)	break;
		if((m = m_div_ss(m, t, 239, &t)) > NMPA)	break;
		if((k += 2) >= RADIX)
		{
			fprintf(stderr, "Error : Too long  in pi()\n");
			break;
		}
		while(i < m)	u.num[i++] = 0;
		if(m_div_ss(m, t, k, &u) > NMPA)	break;
		if(k & 2)	m_add1(&a, u);
		else		m_sub1(&a, u);
	}
	return a;
}

/*	ln2		log(2) --> MPA	*/

MPA ln2(void)
{
	MPA s, t, u, x;
	int k;

	x = m_div_s(_M1, 9);
	s = t = m_div_s(m_set_l(2L), 3);
	k = 3;
	while(s.exp - u.exp <= NMPA)
	{
		m_mul1(&t, x);
		u = m_div_s(t, k);
		m_add1(&s, u);
		k += 2;
	}
	s.sign = 1;
	return s;
}

/*	ln625		log(.625) --> MPA	*/

MPA ln625(void)
{
	MPA s, t, u, x;
	int k;

	x = m_div_s(m_set_l(9L), 169);
	s = t = m_div_s(m_set_l(-6L), 13);
	k = 3;
	while(s.exp - u.exp <= NMPA)
	{
		m_mul1(&t, x);
		u = m_div_s(t, k);
		m_add1(&s, u);
		k += 2;
	}
	return s;
}

/*	ln75		log(.75) --> MPA	*/

MPA ln75(void)
{
	MPA s, t, u, x;
	int k;

	x = m_inv(m_set_l(49L));
	s = t = m_inv(m_set_a("-3.5"));
	k = 3;
	while(s.exp - u.exp <= NMPA)
	{
		m_mul1(&t, x);
		u = m_div_s(t, k);
		m_add1(&s, u);
		k += 2;
	}
	return s;
}
