#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
char* Case(long val, char* one, char* two, char* five)
{
	long t = (val % 100 > 20) ? val % 10 : val % 20;
	
	switch (t)
	{
		case 1:
			return one;
		case 2:
		case 3:
		case 4:
			return two;
		default:
			return five;
	}
}

char* Str(long val, bool male, char* one, char* two, char* five)
{
	char* hunds[] = {
		"", "сто ", "двести ", "триста ", "четыреста ", "пятьсот ", "шестьсот ", "семьсот ",
		"восемьсот ", "девятьсот "
	};
	
	char* tens[] = {
		"", "десять ", "двадцать ", "тридцать ", "сорок ", "пятьдесят ", "шестьдесят ",
		"семьдесят ", "восемьдесят ", "девяносто "
	};
	char* frac20[] = {
		"", "один ", "два ", "три ", "четыре ", "пять ", "шесть ", "семь ", "восемь ", "девять ",
		"десять ", "одиннадцать ", "двенадцать ", "тринадцать ", "четырнадцать ", "пятнадцать ",
		"шестнадцать ", "семнадцать ", "восемнадцать ", "девятнадцать "
	};
	
	long num = val % 1000;
	if (0 == num) return "";
	if (!male)
	{
		frac20[1] = "одна ";
		frac20[2] = "две ";
	}
	
	char* r = (char*)malloc(1000);
	r[0] = 0;
	
	strcpy(r, hunds[num / 100]);
	
	if (num % 100 < 20)
		strcat(r, frac20[num % 100]);
	else
	{
		strcat(r, tens[num % 100 / 10]);
		strcat(r, frac20[num % 10]);
	}
	
	strcat(r, Case(num, one, two, five));
	
	if(strlen(r) != 0)
		strcat(r, " ");
	return r;
}

char* numberToString(double val)
{
	char seniorOne[] = "рубль";
	char seniorTwo[] = "рубля";
	char seniorFive[] = "рублей";
	char juniorOne[] = "копейка";
	char juniorTwo[] = "копейки";
	char juniorFive[] = "копеек";
	
	bool minus = false;
	if (val < 0)
	{
		val = -val;
		minus = true;
	}
	
	long n = (long)val;
	long remainder = (long)((val - n + 0.005) * 100);
	
	char* r = (char*)malloc(1000);
	r[0] = 0;
	char buf[1000];
	
	if (0 == n) strcat(r, "0 ");
	
	if (n % 1000 != 0)
		strcat(r, Str(n, true, seniorOne, seniorTwo, seniorFive));
		else
			strcat(r, seniorFive);
	
	n /= 1000;
	
	strcpy(buf, r);
	strcpy(r, Str(n, false, "тысяча", "тысячи", "тысяч"));
	strcat(r, buf);
	n /= 1000;
	
	strcpy(buf, r);
	strcpy(r, Str(n, true, "миллион", "миллиона", "миллионов"));
	strcat(r, buf);
	n /= 1000;
	
	strcpy(buf, r);
	strcpy(r, Str(n, true, "миллиард", "миллиарда", "миллиардов"));
	strcat(r, buf);
	n /= 1000;
	
	strcpy(buf, r);
	strcpy(r, Str(n, true, "триллион", "триллиона", "триллионов"));
	strcat(r, buf);
	n /= 1000;
	
	strcpy(buf, r);
	strcpy(r, Str(n, true, "квадриллион", "квадриллиона", "квадриллионов"));
	strcat(r, buf);
	if (minus) strcat(r, "минус ");
	
	sprintf(buf, " %02ld ", remainder);
	strcat(r, buf);
	strcat(r, Case(remainder, juniorOne, juniorTwo, juniorFive));
	
	//Делаем первую букву заглавной
	r[0] = toupper(r[0]);
	
	return r;
}



