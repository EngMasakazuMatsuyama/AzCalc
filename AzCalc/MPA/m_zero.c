/*		m_zero.c		*/
#include "mpa.h"

/*		m_z_chk		MPA zero check (when all a.num = 0, a.zero set)	*/

int m_z_chk(MPA *a)
{
	int i;
	UINT *p;

	if(a->zero == 1)	return !0;
	for(i = 0, p = a->num; i <= NMPA; i++)	if(*p++)	return 0;
	a->zero = 1;
	a->sign = 1;
	a->exp = 0;
	return !0;
}
