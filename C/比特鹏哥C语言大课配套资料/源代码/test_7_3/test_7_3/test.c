#define _CRT_SECURE_NO_WARNINGS 1

#include <stdio.h>
//
//int main()
//{
//	int a[5] = { 1, 2, 3, 4, 5 };
//	int* ptr = (int*)(&a + 1);
//
//	printf("%d,%d", *(a + 1), *(ptr - 1));
//	return 0;
//}
//
//
//struct Test
//{
//	int Num;
//	char* pcName;
//	short sDate;
//	char cha[2];
//	short sBa[4];
//}* p = (struct Test*)0x100000;
////����p ��ֵΪ0x100000�� ���±���ʽ��ֵ�ֱ�Ϊ���٣�
////��֪���ṹ��Test���͵ı�����С��20���ֽ�
////x86
//int main()
//{
//	printf("%p\n", p + 0x1);
//	//0x100000+20-->0x100014
//	printf("%p\n", (unsigned long)p + 0x1);
//	//1,048,576+1 --> 1,048,577
//	//0x100001
//	printf("%p\n", (unsigned int*)p + 0x1);
//	//0x100000+4-->0x100004
//	return 0;
//}


//int main()
//{
//	int a[4] = { 1, 2, 3, 4 };
//	int* ptr1 = (int*)(&a + 1);
//	int* ptr2 = (int*)((int)a + 1);
//	printf("%x,%x", ptr1[-1], *ptr2);
//	return 0;
//}
//

//#include <stdio.h>
//int main()
//{
//	int a[3][2] = { (0, 1), (2, 3), (4, 5) };
//	int* p;
//	p = a[0];
//	printf("%d", p[0]);
//	return 0;
//}
//

//int main()
//{
//	int a[5][5];
//	int(*p)[4];
//	p = a;
//	printf("%p,%d\n", &p[4][2] - &a[4][2], &p[4][2] - &a[4][2]);
//	return 0;
//}
//

//int main()
//{
//	int aa[2][5] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
//	int* ptr1 = (int*)(&aa + 1);
//	int* ptr2 = (int*)(*(aa + 1));
//	printf("%d,%d", *(ptr1 - 1), *(ptr2 - 1));
//	return 0;
//}

//#include <stdio.h>
//int main()
//{
//	char* a[] = { "work","at","alibaba" };
//	char** pa = a;
//
//	pa++;
//	printf("%s\n", *pa);
//	return 0;
//}

//int main()
//{
//	char* c[] = { "ENTER","NEW","POINT","FIRST" };
//	char** cp[] = { c + 3,c + 2,c + 1,c };
//	char*** cpp = cp;
//
//	printf("%s\n", **++cpp);
//	printf("%s\n", *-- * ++cpp + 3);
//	printf("%s\n", *cpp[-2] + 3);
//	printf("%s\n", cpp[-1][-1] + 1);
//
//	return 0;
//}

#include <string.h>


//int main()
//{
//	//char arr[] = "abcdef";//abcdef\0
//	char arr[] = { 'b', 'i', 't' };
//	//[][][][][][b][i][t][][][][][][][]
//	int len = strlen(arr);//���ֵ
//
//	printf("%d\n", len);
//
//	return 0;
//}
//


//int main()
//{
//	//        3                  6
//	//if (strlen("abc") - strlen("abcdef") > 0)
//	if (strlen("abc") > strlen("abcdef"))
//	{
//		printf(">\n");
//	}
//	else
//	{
//		printf("<=\n");
//	}
//	return 0;
//}

//ģ��ʵ��
#include <assert.h>

//1.����������
//2.ָ��-ָ��
//3.�ݹ�ķ�ʽ
//size_t my_strlen(const char* str)
//{
//	size_t count = 0;
//	assert(str);
//	while (*str != '\0')
//	{
//		count++;
//		str++;
//	}
//	return count;
//}
//
//int main()
//{
//	char arr[] = "abcdef";
//	size_t n = my_strlen(arr);
//	printf("%u\n", n);
//	return 0;
//}

//int main()
//{
//	char name[3] = "";
//	//"zhangsan"
//	//string copy
//	//
//	char arr[] = "abcdef";
//	strcpy(name, arr);
//
//	//name = "zhansan";//err,name�������ǵ�ַ����ַ��һ������ֵ�����ܱ���ֵ
//
//	printf("%s\n", name);
//
//	return 0;
//}
//
//int main()
//{
//	const char *p = "abcdef";
//	char arr[] = "bit";
//	strcpy(p, arr);//Ŀ�����򲻿��޸�
//
//	return 0;
//}
//

char* my_strcpy(char* dest, const char* src)
{
	assert(dest && src);
	char* ret = dest;
	while (*dest++ = *src++)
		;
	return ret;
}

//�ַ���׷��
char* my_strcat(char*dest, const char* src) 
{
	char* ret = dest;
	assert(dest && src);
	//1. �ҵ�Ŀ��ռ��ĩβ\0
	while (*dest != '\0')
	{
		dest++;
	}
	//2. �����ַ���
	while (*dest++ = *src++)
	{
		;
	}
	return ret;
}

int main()
{
	char arr1[20] = "hello ";
	//my_strcat(arr1, "world");
	//�Լ����Լ�׷�ӣ�
	//my_strcat(arr1, arr1);
	//strcat(arr1, arr1);
	printf("%s\n", arr1);

	//char arr1[] = "abcdef";
	//char arr2[20] = { 0 };
	//my_strcpy(arr2, arr1);
	//printf("%s\n", arr2);//abcdef

	return 0;
}










