#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
//
//struct A
//{
//	int a;//0~3
//	short b;//4~5
//	//6~7
//	int c;//8~11
//	char d;//12
//	//13~15
//};
//
//struct B
//{
//	int a;//0~3
//	short b;//4~5
//	char c;//6
//	//7
//	int d;//8~11
//};
//
//
//int main()
//{
//	printf("%d\n", sizeof(struct A));//16
//	printf("%d\n", sizeof(struct B));//12
//
//	return 0;
//}

//
//#pragma pack(4)/*����ѡ���ʾ4�ֽڶ��� ƽ̨��VS2013�����ԣ�C����*/
//int main(int argc, char* argv[])
//{
//	struct tagTest1
//	{
//		short a;//0~1
//		char d;//2
//		//3
//		long b;//4~7
//		long c;//8~11
//	};//12
//	struct tagTest2
//	{
//		long b;//0~3
//		short c;//4~5
//		char d;//6
//		//7
//		long a;//8~11
//	};//12
//	struct tagTest3
//	{
//		short c;//0~1
//		//2~3
//		long b;//4~7
//		char d;//8
//		//9~11
//		long a;//12~15
//	};//16
//	struct tagTest1 stT1;
//	struct tagTest2 stT2;
//	struct tagTest3 stT3;
//
//	printf("%d %d %d", sizeof(stT1), sizeof(stT2), sizeof(stT3));
//	return 0;
//}
//#pragma pack()



//#define MAX_SIZE 2+3
//struct _Record_Struct
//{
//	unsigned char Env_Alarm_ID : 4;//1byte-8bit
//	unsigned char Para1 : 2;
//	unsigned char state;//1byte-8bite
//	unsigned char avail : 1;//1byte=8bit
//}*Env_Alarm_Record;
//
//struct _Record_Struct* pointer = (struct _Record_Struct*)malloc(sizeof(struct _Record_Struct) * 2 + 3);
//��A = 2�� B = 3ʱ��pointer���䣨 �����ֽڵĿռ䡣

//int main()
//{
//    unsigned char puc[4];
//    struct tagPIM
//    {
//        unsigned char ucPim1;
//        unsigned char ucData0 : 1;
//        unsigned char ucData1 : 2;
//        unsigned char ucData2 : 3;
//    }*pstPimData;
//    pstPimData = (struct tagPIM*)puc;
//    memset(puc, 0, 4);
//
//    pstPimData->ucPim1 = 2;
//    pstPimData->ucData0 = 3;
//    pstPimData->ucData1 = 4;
//    pstPimData->ucData2 = 5;
//    printf("%02x %02x %02x %02x\n", puc[0], puc[1], puc[2], puc[3]);
//    return 0;
//}

//%02x
//16���Ƶ���ʽ��ӡ����ӡ2λ���������2λ����0���

//#include <stdio.h>
//union Un
//{
//	short s[7];
//	int n;
//};
//int main()
//{
//	printf("%d\n", sizeof(union Un));
//	return 0;
//}


//#include<stdio.h>
//int main()
//{
//    union
//    {
//        short k;
//        char i[2];
//    }*s, a;
//    s = &a;
//    s->i[0] = 0x39;
//    s->i[1] = 0x38;
//    printf("%x\n", a.k);
//
//    return 0;
//}

//һ��������ֻ�����������ǳ���һ�Σ������������ֶ����������Ρ�
//��дһ�������ҳ�������ֻ����һ�ε����֡�
//
//void find_single_dog(int arr[], int sz, int *pd1, int*pd2)
//{
//	int i = 0;
//	int ret = 0;
//	//1.���
//	for (i = 0; i < sz; i++)
//	{
//		ret ^= arr[i];
//	}
//	//2. ����ret�Ķ����������ұߵĵڼ�λ��1
//	int pos = 0;
//	for (pos=0; pos < 32; pos++)
//	{
//		if (((ret >> pos) & 1) == 1)
//		{
//			break;
//		}
//	}
//	for (i = 0; i < sz; i++)
//	{
//		if (((arr[i] >> pos) & 1) == 1)
//		{
//			*pd1 ^= arr[i];
//		}
//		else
//		{
//			*pd2 ^= arr[i];
//		}
//	}
//}
//int main()
//{
//	//1 2 3 4 5 1 2 3 4 6
//	//1 2 3 4 5 1 2 3 4
//	//
//	int arr[] = { 1,2,3,4,5,1,2,3,4,6 };
//	int sz = sizeof(arr) / sizeof(arr[0]);
//	int dog1 = 0;
//	int dog2 = 0;
//	find_single_dog(arr, sz, &dog1, &dog2);
//	printf("%d %d\n", dog1, dog2);
//	//5^6
//	//101 - 5 B 1 1 3 3
//	//110 - 6 A 2 2 4 4
//	//011
//	//    - 5 B 1 1 4 4
//	//    - 6 A 2 2 3 3 
//	//����
//	//1. �����������
//	//2. �ҳ����Ľ����������һλΪ1 - n
//	//3. �Ե�nΪ1����һ�飬��nλΪ0��һ��
//	return 0;
//}\
// 


//leetcode �ύ�İ汾
//https://leetcode.cn/problems/single-number-iii/

/**
 * Note: The returned array must be malloced, assume caller calls free().
 */
//int* singleNumber(int* nums, int numsSize, int* returnSize) {
//	int* pret = (int*)calloc(2, sizeof(int));
//	int i = 0;
//	int ret = 0;
//	//1.���
//	for (i = 0; i < numsSize; i++)
//	{
//		ret ^= nums[i];
//	}
//	//2. ����ret�Ķ����������ұߵĵڼ�λ��1
//	int pos = 0;
//	for (pos = 0; pos < 32; pos++)
//	{
//		if (((ret >> pos) & 1) == 1)
//		{
//			break;
//		}
//	}
//	for (i = 0; i < numsSize; i++)
//	{
//		if (((nums[i] >> pos) & 1) == 1)
//		{
//			pret[0] ^= nums[i];
//		}
//		else
//		{
//			pret[1] ^= nums[i];
//		}
//	}
//	*returnSize = 2;
//	return pret;
//}


//
//
#include <stdlib.h>
#include <assert.h>
//1. ��ָ��
//2. ���ַ���
//3. �ո�
//4. +-
//5. Խ��
//6. �������ַ�
//
//
//#include <ctype.h>
//#include <limits.h>
//
//enum Status
//{
//	VALID,
//	INVALID
//}sta = INVALID;//Ĭ�ϷǷ�
//
//
//int my_atoi(const char* str)
//{
//	int flag = 1;
//	assert(str);
//	if (*str == '\0')
//		return 0;//�Ƿ�0
//	//�����հ��ַ�
//	while (isspace(*str))
//	{
//		str++;
//	}
//	//+-
//	if (*str == '+')
//	{
//		flag = 1;
//		str++;
//	}
//	else if(*str == '-')
//	{
//		flag = -1;
//		str++;
//	}
//
//	long long ret = 0;
//	while (*str)
//	{
//		if (isdigit(*str))
//		{
//			//Խ��
//			ret = ret * 10 + flag*(*str - '0');
//			if (ret > INT_MAX || ret < INT_MIN)
//			{
//				return 0;
//			}
//		}
//		else
//		{
//			return (int)ret;
//		}
//		str++;
//	}
//	if (*str == '\0')
//	{
//		sta = VALID;
//	}
//	return (int)ret;
//}
//
//int main()
//{
//	char arr[200] = "+1234";
//	int ret = my_atoi(arr);
//	if (sta == INVALID)
//	{
//		printf("�Ƿ�����:%d\n", ret);
//	}
//	else if (sta == VALID)
//	{
//		printf("�Ϸ�ת��:%d\n", ret);
//	}
//
//	return 0;
//}


//
//leetcode
//����ָoffer��
//

//
//
//int main()
//{
//    long num = 0;
//    FILE* fp = NULL;
//    //...
//    if ((fp = fopen("fname.dat", "r")) == NULL)
//    {
//        printf("Can��t open the file! ");
//        exit(0);
//    }
//    while (fgetc(fp) != EOF)
//    {
//        num++;
//    }
//    printf("num=%d\n", num);
//    fclose(fp);
//    return 0;
//}
//


//#define INT_PTR int*
//typedef int* int_ptr;
//
//int *a, b;//a��������int*,b��������int
//int_ptr c, d;//c��d����ָ������

//
//#define N 4
//
//#define Y(n) ((4+2)*5 + 1)
//
//��ִ����䣺z = 2 * (4 + ((4 + 2) * 5 + 1)); ��z��ֵΪ�� ��


//#define A 2+2
//#define B 3+3
//#define C 2+2*3+3
//int main()
//{
//	printf("%d\n", 2 + 2 * 3 + 3);
//	return 0;
//}
//

//дһ���꣬���Խ�һ�������Ķ�����λ������λ��ż��λ������
//
//#define SWAP_BIT(n) n=(((n&0x55555555)<<1)+((n&0xaaaaaaaa)>>1))
//
////-2
////100000000000000000000000000000010
////111111111111111111111111111111101
////111111111111111111111111111111110
////
////111111111111111111111111111111101
////111111111111111111111111111111100
////100000000000000000000000000000011
////-3
////10000000000000000000000000000001
////10000000000000000000000000000000
////11111111111111111111111111111111
////
//int main()
//{
//	//10
//	//1010 - 10
//	//0101 - 5
//	int n = 0;
//	scanf("%d", &n);
//	SWAP_BIT(n);
//	printf("%d\n", n);
//	return 0;
//}
//


int main()
{
	return 0;
}