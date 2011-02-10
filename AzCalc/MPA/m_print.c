/*		m_print.c		MPA print out in decimal */
#include "mpa.h"


void m_string(char *rs, MPA a)   // rs[256]:結果文字列を出力する
{
	int i, m, mmpa, mp, n, nmpa, zflag;
	UINT c[MMPA], t[NMPA1];
	UINT *cp, *p, *q, w;
	ULONG u;
	int irs = 0;
	
	nmpa = 10;  // (_short)? 10: NMPA;
	mmpa = 12;  // (_short)? 12: MMPA - 1;
	//if(mmpa < fabs(a.exp))
	if(mmpa < abs(a.exp))
	{
		//m_printe(s, a, _short);
		sprintf(rs, "NG\0");
		return;
	}
	if(a.zero == 1)
	{
		//printf("%s 0\n", s);
		sprintf(rs, "0\0");
		return;
	}
	//printf("%s ", s);
	for(i = 0, cp = c; i <= mmpa; i++)	*cp++ = 0;
	if(a.sign == 1)	rs[irs++] = '+'; // putchar('+');
	else			rs[irs++] = '-'; // putchar('-');
	cp = c;
	m = 0;
	n = a.exp;
	mp = -1;
	if(n >= 0)
	{
		for(i = 0, p = a.num, q = t; i <= n; i++)	*q++ = *p++;
		while(1)
		{
			u = 0;
			for(i = 0, p = t; i <= n; i++)
			{
				u = (u << RADIXBITS) + *p;
				*p++ = u / 10000;
				u %= 10000;
			}
			*cp++ = u;
			m++;
			mp++;
			for(i = 0, p = t, zflag = 1; i <= n; i++)
			{
				if(*p++)
				{
					zflag = 0;
					break;
				}
			}
			if(zflag)	break;
		}
		for(p = c, q = c + m - 1; p < q; p++, q--)
		{
			w = *p;
			*p = *q;
			*q = w;
		}
		for(i = n + 1, p = a.num, q = a.num + i; i <= nmpa; i++)	*p++ = *q++;
		for(i = 0; i <= n; i++)	*p++ = 0;
		a.exp = -1;
	}
	else if(n < -1)
	{
		while(1)
		{
			m_mul1_s(&a, 10000);
			if(a.exp < 0)	mp--;
			else
			{
				*cp++ = a.num[0];
				m++;
				break;
			}
		}
		for(i = 1, p = a.num, q = p + 1; i <= nmpa; i++)	*p++ = *q++;
		*p = 0;
		a.exp = -1;
	}
	i = 0;
	m_mul1_s(&a, 10000);
	m++;
	if(a.exp == 0)
	{
		*cp++ = a.num[0];
		a.num[0] = 0;
	}
	else	*cp++ = 0;
	while(m <= mmpa)
	{
		if(m_z_chk(&a))	break;
		m_mul1_s(&a, 10000);
		*cp++ = a.num[0];
		m++;
		a.num[0] = 0;
	}
	if(*(c + mmpa) < 5000)	*(c + mmpa) = 0;
	else
	{
		*(c + mmpa) = 0;
		for(m = mmpa - 1, cp = c + m; m >= 0; m--)
		{
			(*cp)++;
			if(*cp != 10000)	break;
			*cp-- = 0;
		}
	}
	for(cp = c + mmpa, p = c; cp >= p; )
	{
		if(*cp--)	break;
		mmpa--;
	}
	if(mmpa < 0)
	{
		//printf("0\n");
		rs[irs++] = '0';
		rs[irs++] = '\0';
		return;
	}
	//i = strlen(s) + 2;
	i = 2;
	if(mp < 0)
	{
		//printf("0.");
		rs[irs++] = '0';
		rs[irs++] = '.';
		while(++mp < 0)
		{
			//if((i = (i + 5) % 78) < 5)
			//{
			//	putchar('\n');
			//	i = 5;
			//}
			//printf("0000 ");
			rs[irs++] = '0';
			rs[irs++] = '0';
			rs[irs++] = '0';
			rs[irs++] = '0';
		}
		mp = -1;
	}
	cp = c;
	if(mp < 0) {
		//printf("%04u ", *cp++);
		irs += sprintf(&rs[irs], "%04u", *cp++);
	} 
	else
	{
		//printf("%u", *cp++);
		irs += sprintf(&rs[irs], "%u", *cp++);  // 整数部の先頭の0を除くために %04u にしない

		//if(mp)	rs[irs++] = '@';  // putchar(' ');
		//else		rs[irs++] = '.';  // putchar('.');
		if(!mp)		rs[irs++] = '.';
	}
	//if((i = (i + 5) % 78) < 5)
	//{
	//	putchar('\n');
	//	i = 5;
	//}
	for(m = 1; m <= mmpa; m++)
	{
		//if((i = (i + 5) % 78) < 5)
		//{
		//	putchar('\n');
		//	i = 5;
		//}
		//printf("%04u", *cp++);
		irs += sprintf(&rs[irs], "%04u", *cp++);
		
		if(m == mp)	rs[irs++] = '.';  // putchar('.');
		//else		rs[irs++] = '$';  // putchar(' ');
	}
	if(m < mp)
	{
		do
		{
			//if((i = (i + 5) % 78) < 5)
			//{
			//	putchar('\n');
			//	i = 5;
			//}
			//printf("0000 ");
			rs[irs++] = '0';
			rs[irs++] = '0';
			rs[irs++] = '0';
			rs[irs++] = '0';
		}while(m++ < mp);
	}
	//putchar('\n');
	rs[irs] = '\0';
	return;
}

void m_print(char *s, MPA a, int _short)
{
	int i, m, mmpa, mp, n, nmpa, zflag;
	UINT c[MMPA], t[NMPA1];
	UINT *cp, *p, *q, w;
	ULONG u;
	
	nmpa = (_short)? 10: NMPA;
	mmpa = (_short)? 12: MMPA - 1;
	//if(mmpa < fabs(a.exp))
	if(mmpa < abs(a.exp))
	{
		m_printe(s, a, _short);
		return;
	}
	if(a.zero == 1)
	{
		printf("%s 0\n", s);
		return;
	}
	printf("%s ", s);
	for(i = 0, cp = c; i <= mmpa; i++)	*cp++ = 0;
	if(a.sign == 1)	putchar('+');
	else			putchar('-');
	cp = c;
	m = 0;
	n = a.exp;
	mp = -1;
	if(n >= 0)
	{
		for(i = 0, p = a.num, q = t; i <= n; i++)	*q++ = *p++;
		while(1)
		{
			u = 0;
			for(i = 0, p = t; i <= n; i++)
			{
				u = (u << RADIXBITS) + *p;
				*p++ = u / 10000;
				u %= 10000;
			}
			*cp++ = u;
			m++;
			mp++;
			for(i = 0, p = t, zflag = 1; i <= n; i++)
			{
				if(*p++)
				{
					zflag = 0;
					break;
				}
			}
			if(zflag)	break;
		}
		for(p = c, q = c + m - 1; p < q; p++, q--)
		{
			w = *p;
			*p = *q;
			*q = w;
		}
		for(i = n + 1, p = a.num, q = a.num + i; i <= nmpa; i++)	*p++ = *q++;
		for(i = 0; i <= n; i++)	*p++ = 0;
		a.exp = -1;
	}
	else if(n < -1)
	{
		while(1)
		{
			m_mul1_s(&a, 10000);
			if(a.exp < 0)	mp--;
			else
			{
				*cp++ = a.num[0];
				m++;
				break;
			}
		}
		for(i = 1, p = a.num, q = p + 1; i <= nmpa; i++)	*p++ = *q++;
		*p = 0;
		a.exp = -1;
	}
	i = 0;
	m_mul1_s(&a, 10000);
	m++;
	if(a.exp == 0)
	{
		*cp++ = a.num[0];
		a.num[0] = 0;
	}
	else	*cp++ = 0;
	while(m <= mmpa)
	{
		if(m_z_chk(&a))	break;
		m_mul1_s(&a, 10000);
		*cp++ = a.num[0];
		m++;
		a.num[0] = 0;
	}
	if(*(c + mmpa) < 5000)	*(c + mmpa) = 0;
	else
	{
		*(c + mmpa) = 0;
		for(m = mmpa - 1, cp = c + m; m >= 0; m--)
		{
			(*cp)++;
			if(*cp != 10000)	break;
			*cp-- = 0;
		}
	}
	for(cp = c + mmpa, p = c; cp >= p; )
	{
		if(*cp--)	break;
		mmpa--;
	}
	if(mmpa < 0)
	{
		printf("0*****************\n"); //***********************************************
		return;
	}
	i = strlen(s) + 2;
	if(mp < 0)
	{
		printf("0.");
		while(++mp < 0)
		{
			if((i = (i + 5) % 78) < 5)
			{
				putchar('\n');
				i = 5;
			}
			printf("0000 ");
		}
		mp = -1;
	}
	cp = c;
	if(mp < 0)	printf("%04u ", *cp++);
	else
	{
		printf("%u", *cp++);
		if(mp)	putchar(' ');
		else	putchar('.');
	}
	if((i = (i + 5) % 78) < 5)
	{
		putchar('\n');
		i = 5;
	}
	for(m = 1; m <= mmpa; m++)
	{
		if((i = (i + 5) % 78) < 5)
		{
			putchar('\n');
			i = 5;
		}
		printf("%04u", *cp++);
		if(m == mp)	putchar('.');
		else		putchar(' ');
	}
	if(m < mp)
	{
		do
		{
			if((i = (i + 5) % 78) < 5)
			{
				putchar('\n');
				i = 5;
			}
			printf("0000 ");
		}while(m++ < mp);
	}
	putchar('\n');
	return;
}

void m_printe(char *s, MPA a, int _short)
{
	MPA r, t;
	int ex;

	ex = a.exp;
	a.exp = 0;
	t = m_add(m_log(a), m_mul_s(_LNRADIX, ex));
	t = m_idiv(t, _LN10, &r);
	printf("%s\n", s);
	printf("exponent(éwêîïî) = %ld\n", m_iset_s(t));
	printf("significant(âºêîïî) =\n");
	m_print("", m_10(r), _short);
}

/*		m_prt_b			MPA print out  in bit image	*/

void m_prt_b(char *s, MPA a, int _short)
{
	int i, j, nmpa;
	UINT n, *p;

	nmpa = (_short)? 10: NMPA;
	puts(s);
	printf(" zero = %d   sign = %d   exp = %d\n", a.zero, a.sign, a.exp);
	for(i = 0, p = a.num; i < nmpa; i++)
	{
		for(j = 0, n = *p++; j < RADIXBITS; j++)
		{
			if((n <<= 1) & RADIX)	putchar('1');
			else					putchar('0');
		}
		putchar(' ');
	}
	putchar('\n');
	return;
}

/*		m_prt_m		MPA print out in RADIX	*/

void m_prt_m(char *s, MPA a, int _short)
{
	int flag, i, l, n, nn;
	UINT *p;

	printf("%s : ", s);
	printf("<%+5d> ", a.exp);
	if(a.zero)
	{
		printf("0\n");
		return;
	}
	l = 15;
	nn = 60;
	if(a.sign == 1)	putchar('+');
	else			putchar('-');
	p = a.num;
	printf("%5u.", *p);
	n = nn;
	flag = 0;
	while(1)
	{
		*p++ = 0;
		if(m_z_chk(&a))	break;
		if(flag)	for(i = 1; i <= l; i++)	putchar(' ');
		printf(" %05u", *p);
		n -= 6;
		if(n >= 6)	flag = 0;
		else
		{
			putchar('\n');
			if(_short)	return;
			flag = 1;
			n = nn;
		}
	}
	if(!flag)	putchar('\n');
	return;
}
