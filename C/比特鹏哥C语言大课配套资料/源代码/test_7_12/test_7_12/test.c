#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>

//enum Day//����
//{
//	Mon,//0
//	Tues,//1
//	Wed,//2
//	Thur,//3
//	Fri,//4
//	Sat,//5
//	Sun//6
//};
//
//enum Day//����
//{
//	//ö�ٳ���
//	Mon=1,
//	Tues,
//	Wed,
//	Thur,
//	Fri,
//	Sat,
//	Sun
//};
//
////#define Mon 1
////#define Tues 2
////....
//
//#define M 100
//
//int main()
//{
//	enum Day d = Fri;
//	int m = M;
//
//	/*printf("%d\n", Mon);
//	printf("%d\n", Tues);
//	printf("%d\n", Wed);
//	printf("%d\n", Thur);
//	printf("%d\n", Fri);
//	printf("%d\n", Sat);
//	printf("%d\n", Sun);*/
//	return 0;
//}
//

//struct Stu
//{
//	int a;
//	char c;
//};
//struct St
//{
//	int a;
//	char c;
//};
//
//union Un
//{
//	int a;//4
//	char c;//1
//};
//
//
////����
//int main()
//{
//	union Un u;
//	u.a = 0x11223344;
//	u.c = 0x00;
//	//printf("%d\n", sizeof(u));//?
//
//	//printf("%p\n", &u);
//	//printf("%p\n", &(u.a));
//	//printf("%p\n", &(u.c));
//
//	return 0;
//}

//�жϵ�ǰ������Ĵ�С�˴洢

//1
//int check_sys()
//{
//	int a = 1;
//	return *(char*)&a;
//}
//
//int check_sys()
//{
//	union
//	{
//		char c;
//		int i;
//	}u;
//	u.i = 1;
//	//����1��С�ˣ�����0�Ǵ��
//	return u.c;
//}
//int main()
//{
//	//int a = 1;//0x 00 00 00 01
//	//��-------> ��
//	//01 00 00 00 -- С��
//	//00 00 00 01 -- ���
//	int ret = check_sys();
//	if (ret == 1)
//		printf("С��\n");
//	else
//		printf("���\n");
//
//	return 0;
//}
//

//union Un
//{
//	char arr[5];//5
//	int i;//4
//};
//
//union Un
//{
//	short arr[7];//14
//	int i;//4
//};
//
//
//int main()
//{
//	printf("%d\n", sizeof(union Un));
//
//	return 0;
//}
//
//
//union Un
//{
//	char arr[5];
//	int i;//4
//};
//
//union Un1
//{
//	char c1;
//	char c2;
//	char c3;
//	char c4;
//	char c5;
//
//	int i;//4
//};


//int main()
//{
//	int a = 10;//4���ֽ�
//	int arr[10];//40���ֽ�
//
//	return 0;
//}


//100
//120
//20
#include <errno.h>
#include <string.h>
#include <stdlib.h>

//
//�䳤����
//c99��׼֧�ֵı䳤����
//int n = 0;
//scanf("%d", &n);
//int arr2[n];
//
//int main()
//{
//	int arr[10] = {0};
//	//��̬�ڴ濪��
//	int*p = (int*)malloc(40);
//	if (p == NULL)
//	{
//		printf("%s\n", strerror(errno));
//		return 1;
//	}
//	//ʹ��
//	int i = 0;
//	for (i = 0; i < 10; i++)
//	{
//		*(p + i) = i;
//	}
//	for (i = 0; i < 10; i++)
//	{
//		printf("%d ", *(p + i));
//	}
//
//	//û��free
//	//������˵�ڴ�ռ�Ͳ�������
//	//�������˳���ʱ��ϵͳ���Զ������ڴ�ռ��
//
//	return 0;
//}
//int main()
//{
//	int arr[10] = { 0 };
//	//��̬�ڴ濪��
//	int* p = (int*)malloc(40);
//	if (p == NULL)
//	{
//		printf("%s\n", strerror(errno));
//		return 1;
//	}
//	//ʹ��
//	int i = 0;
//	for (i = 0; i < 10; i++)
//	{
//		*(p + i) = i;
//	}
//	for (i = 0; i < 10; i++)
//	{
//		printf("%d ", *(p + i));
//	}
//	
//	free(p);
//	p = NULL;
//
//	return 0;
//}



//int main()
//{
//	while (1)
//	{
//		malloc(1);
//	}
//
//	return 0;
//}


//int main()
//{
//	int a = 10;
//	int* p = &a;
//	//....
//	free(p);
//	p = NULL;
//	return 0;
//}

//int main()
//{
//	//malloc
//	int* p = NULL;
//	free(p);
//
//	return 0;
//}

//����10�����͵Ŀռ�
//int main()
//{
//	int*p = (int*)calloc(10, sizeof(int));
//	if (p == NULL)
//	{
//		printf("%s\n", strerror(errno));
//		return 1;
//	}
//	//��ӡ
//	int i = 0;
//	for (i = 0; i < 10; i++)
//	{
//		printf("%d ", *(p + i));
//	}
//	//�ͷ�
//	free(p);
//	p = NULL;
//
//	return 0;
//}
//
//int main()
//{
//	int*p = (int*)malloc(40);
//	if (NULL == p)
//	{
//		printf("%s\n", strerror(errno));
//		return 1;
//	}
//	//ʹ��
//	//1 2 3 4 5 6 7 8 9 10
//	int i = 0;
//	for (i = 0; i < 10; i++)
//	{
//		*(p + i) = i + 1;
//	}
//	//����
//	int* ptr = (int*)realloc(p, 8000);
//	if (ptr != NULL)
//	{
//		p = ptr;
//	}
//	//ʹ��
//	for (i = 0; i < 10; i++)
//	{
//		printf("%d ", *(p + i));
//	}
//	free(p);
//	p = NULL;
//
//	return 0;
//}
//

//int main()
//{
//	realloc(NULL, 40);//malloc(40);
//	return 0;
//}




