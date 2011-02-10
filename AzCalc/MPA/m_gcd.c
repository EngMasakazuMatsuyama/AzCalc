/*		m_gcd.c		GCD(MPA, MPA) --> MPA	(Greatest Common Divisor)	*/
#include "mpa.h"

MPA m_gcd(MPA a, MPA b)
{
	MPA x;

	x = m_frac(a);
	if(!m_z_chk(&x))
	{
		fprintf(stderr, "Error : Not integer (MPA a)  in m_gcd()\n");
		return _M0;
	}
	x = m_frac(b);
	if(!m_z_chk(&x))
	{
		fprintf(stderr, "Error : Not integer (MPA b)  in m_gcd()\n");
		return _M0;
	}
	if(a.sign == 0 || b.sign == 0)
	{
		fprintf(stderr, "Error : Illegal parameter  in m_gcd()\n");
		return _M0;
	}
	x = _M0;
	do
	{
		a = m_idiv(a, b, &x);
		a = b;
		b = x;
	} while(!m_z_chk(&b));
	return a;
}

/*		m_lcm		LCM (MPA, MPA) --> MPA		(Least Common Multiple)	*/

MPA m_lcm(MPA a, MPA b)
{
	MPA x;

	x = m_frac(a);
	if(!m_z_chk(&x))
	{
		fprintf(stderr, "Error : Not integer (MPA a)  in m_lcm()\n");
		return _M0;
	}
	x = m_frac(b);
	if(!m_z_chk(&x))
	{
		fprintf(stderr, "Error : Not integer (MPA b)  in m_lcm()\n");
		return _M0;
	}
	if(a.sign == 0 || b.sign == 0)
	{
		fprintf(stderr, "Error : Illegal parameter  in m_lcm()\n");
		return _M0;
	}
	return m_idiv(m_mul(a, b), m_gcd(a, b), &b);
}

/*		m_kaijo			n! --> MPA	*/

MPA m_kaijo(UINT n)
{
	MPA a;
	UINT i;

	if(n > _MAX_KAIJO)
	{
		fprintf(stderr, "Error : Overflow  in m_kaijo()\n");
		return _MMAX;
	}
	a = _M1;
	if(n <= 1)	return a;;
	i = 2;
	while(i <= n)	m_mul1_s(&a, i++);
	return a;
}

/*		m_bino		Binominal coefficient		mCn		*/

MPA m_bino(UINT m, UINT n)
{
	if(m < n)
	{
		fprintf(stderr, "Error : Illegal parameter in m_bino()\n");
		return _M0;
	}
	if(m == n)	return _M1;
	return m_div(m_div(m_kaijo(m), m_kaijo(n)), m_kaijo(m - n));
}
