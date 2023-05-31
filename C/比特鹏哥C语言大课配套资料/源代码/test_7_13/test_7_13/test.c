#define _CRT_SECURE_NO_WARNINGS 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

//1.��NULLָ��Ľ����ò���
//int main()
//{
//	int* p = (int*)malloc(40);
//	if (p == NULL)
//	{
//		return 1;
//	}
//	*p = 20;
//	free(p);
//	p = NULL;
//
//	return 0;
//}

//2.�Զ�̬���ٿռ��Խ�����
//
//int main()
//{
//	int* p = (int*)malloc(40);
//	if (p == NULL)
//	{
//		printf("%s\n", strerror(errno));
//		return 1;
//	}
//	//��ʽ
//	int i = 0;
//	for (i = 0; i <= 10; i++)
//	{
//		p[i] = i;
//	}
//
//	free(p);
//	p = NULL;
//	return 0;
//}

//3.�ԷǶ�̬�����ڴ�ʹ��free�ͷ�

//int main()
//{
//	int a = 10;
//	int* p = &a;
//	//.....
//
//	free(p);
//	p = NULL;
//
//	return 0;
//}

//4.  ʹ��free�ͷ�һ�鶯̬�����ڴ��һ����

//int main()
//{
//	int* p = (int*)malloc(40);
//	if (p == NULL)
//	{
//		return 1;
//	}
//	//ʹ��
//	int i = 0;
//	for (i = 0; i < 5; i++)
//	{
//		*p = i;
//		p++;
//	}
//
//	//�ͷ�
//	free(p);
//	p = NULL;
//
//	return 0;
//}

//5. ��ͬһ�鶯̬�ڴ����ͷ�

//int main()
//{
//	int* p = (int*)malloc(40);
//	//....
//	free(p);
//	p = NULL;
//	//...
//	free(p);
//
//	return 0;
//}


//6.��̬�����ڴ������ͷţ��ڴ�й©��

//void test()
//{
//	int* p = (int*)malloc(100);
//	//....
//	int flag = 0;
//	scanf("%d", &flag);//5
//	if (flag == 5)
//		return;
//
//	free(p);
//	p = NULL;
//}
//
//int main()
//{
//	test();
//	//......
//
//
//	return 0;
//}
//


//int* test()
//{
//	//���ٵ�
//	int* p = (int*)malloc(100);
//	if (p == NULL)
//	{
//		return p;
//	}
//	//....
//	return p;
//}
//
//int main()
//{
//	int* ret = test();
//	//�����ͷ���
//
//	return 0;
//}
//
//void GetMemory(char** p)
//{
//	*p = (char*)malloc(100);
//}
//void Test(void)
//{
//	char* str = NULL;
//	GetMemory(&str);
//	//str��ŵľ��Ƕ�̬���ٵ�100�ֽڵĵ�ַ
//	strcpy(str, "hello world");
//	printf(str);
//	//�ͷ�
//	free(str);
//	str = NULL;
//}
//
//int main()
//{
//	Test();
//	return 0;
//}


//char* GetMemory(char* p)
//{
//	p = (char*)malloc(100);
//	return p;
//}
//void Test(void)
//{
//	char* str = NULL;
//	str = GetMemory(str);
//	//str��ŵľ��Ƕ�̬���ٵ�100�ֽڵĵ�ַ
//	strcpy(str, "hello world");
//	printf(str);
//	free(str);
//	str = NULL;
//}
//int main()
//{
//	Test();
//	return 0;
//}


//int main()
//{
//	printf("hello world\n");
//	char* p = "hello world\n";
//	printf(p);
//	printf("%s", p);
//
//	return 0;
//}
//

//
//char* GetMemory(void)
//{
//	//����ջ�ռ�ĵ�ַ������
//	char p[] = "hello world";
//	return p;
//}
//void Test(void)
//{
//	char* str = NULL;
//	str = GetMemory();
//	printf(str);
//}
//
//int main()
//{
//	Test();
//	return 0;
//}

//
//int* test()
//{
//	//����ջ�ռ�ĵ�ַ������
//	int a = 10;
//	return &a;
//}
//
//int main()
//{
//	int*p = test();
//	printf("hehe\n");
//	printf("%d\n", *p);
//
//	return 0;
//}

//void GetMemory(char** p, int num)
//{
//	*p = (char*)malloc(num);
//}
//
//void Test(void)
//{
//	char* str = NULL;
//	GetMemory(&str, 100);
//	strcpy(str, "hello");
//	printf(str);
//	free(str);
//	str = NULL;
//}
//
//int main()
//{
//	Test();
//	return 0;
//}
//

//void Test(void)
//{
//	char* str = (char*)malloc(100);
//	strcpy(str, "hello");
//	free(str);
//	str = NULL;
//
//	if (str != NULL)
//	{
//		strcpy(str, "world");
//		printf(str);
//	}
//}
//
//int main()
//{
//	Test();
//	return 0;
//}


//
//#include <stdio.h>
//
//int main()
//{
//    int n = 0;
//    int m = 0;
//
//    while (scanf("%d %d", &n, &m) == 2)
//    {
//        int min = n < m ? n : m;
//        int max = n > m ? n : m;
//        int i = min;
//        int j = max;
//        //
//        while (1)
//        {
//            if (n % i == 0 && m % i == 0)
//            {
//                break;
//            }
//            i--;
//        }
//        //i�������Լ��
//        while (1)
//        {
//            if (j % n == 0 && j % m == 0)
//            {
//                break;
//            }
//            j++;
//        }
//        //j������С������
//        printf("%d\n", i + j);
//    }
//    return 0;
//}
//
//
//#include <stdio.h>
//
//int main()
//{
//    long n = 0;
//    long m = 0;
//
//    while (scanf("%ld %ld", &n, &m) == 2)
//    {
//        //1
//        long i = n;
//        long j = m;
//        long r = 0;
//        while (r = i % j)
//        {
//            i = j;
//            j = r;
//        }
//        //j�������Լ��
//        //n*m/�;�����С������
//
//        printf("%ld\n", m * n / j + j);
//        /*
//        int min = n<m?n:m;
//        int max = n>m?n:m;
//        int i = min;
//        int j = max;
//        //
//        while(1)
//        {
//            if(n%i==0 && m%i==0)
//            {
//                break;
//            }
//            i--;
//        }
//        //i�������Լ��
//        while(1)
//        {
//            if(j%n==0 && j%m==0)
//            {
//                break;
//            }
//            j++;
//        }
//        //j������С������
//        printf("%d\n", i+j);
//        */
//    }
//    return 0;
//}
//
//
//int main()
//{
//    int n = 0;
//    while (scanf("%d", &n) == 1)
//    {
//        int i = 0;
//        int j = 0;
//        for (i = 0; i < n; i++)
//        {
//            for (j = 0; j < n; j++)
//            {
//                printf("* ");
//            }
//            printf("\n");
//        }
//    }
//    return 0;
//}

#include <stdio.h>

int main()
{
    int n = 0;
    while (scanf("%d", &n) == 1)
    {
        int i = 0;
        int j = 0;
        for (i = 0; i < n; i++)
        {
            for (j = 0; j < n; j++)
            {
                if (i == 0 || i == n - 1 || j == 0 || j == n - 1)
                    printf("* ");
                else
                    printf("  ");
            }
            printf("\n");
        }
    }
    return 0;
}

