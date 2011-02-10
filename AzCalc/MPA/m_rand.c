/*		m_rand.c		random MPA		*/
#include "mpa.h"

unsigned long *_prx, *_prx_end;			/* mrnd()ÇÃóêêîäjÇŸÇ©ïœêî */
unsigned long _rx[522];					/*      ÅV        */

void rnd521(void);
int mrnd(void);

MPA m_rand(void)
{
	MPA r;
	unsigned long t;
	int i;

	for(i = 0; i <= NMPA; i += 2)	r.num[i] = mrnd();
	r.zero = 0;
	r.sign = 1;
	if(r.num[NMPA] != 0)	r.exp = -1;
	else
	{
		i = mrnd();
		r.exp = -2;
		while(i < RADIX_2)
		{
			r.exp--;
			i <<= 1;
		}
	}
	return r;
}

void rnd521(void)
{
	unsigned long *p, *p1, *p2;

	p1 = (_prx = p = p2 = _rx) + 489;
	while(p1 != _prx_end)	*p++ ^= *p1++;
	while(p  != _prx_end)	*p++ ^= *p2++;
}

int mrnd(void)
{
	static int sw = 1, rnd;

	if(sw)
	{
		sw = 0;
		if(++_prx == _prx_end)	rnd521();
		rnd = *_prx & RADIX1;
		return *_prx >> (RADIXBITS + 1);
	}
	sw = 1;
	return rnd;
}

void m_srand(long seed)
{
	int i, j;
	unsigned long *p, *p1, *p2, *p3, s, u;

	_prx_end = &_rx[521];

	s = seed ^ 987612345L;
	u = 0;
	for(i = 0, _prx = _rx; i <= 16; i++)
	{
		for(j = 0; j < 32; j++)
		{
			s = s * 1566083941L + 1;
			u = (u >> 1) | (s & (1L << 31));
		}
		*_prx++ = u;
	}
	_prx--;
	*_prx = (0xffffffff & (*_prx << 23)) ^ (*_rx >> 9) ^ *(_rx + 15);
	p1 = _rx;
	p2 = &_rx[1];
	p3 = _prx++;
	while(_prx != _prx_end)
		*_prx++ = (0xffffffff & (*p1++ << 23)) ^ (*p2++ >> 9) ^ *p3++;
	rnd521();		/* wram up */
	rnd521();
	rnd521();
	_prx = &_rx[520];
}
