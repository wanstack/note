#define _CRT_SECURE_NO_WARNINGS

#include <stdio.h>

//
//int main()
//{
//	int i = 0;
//	int arr[10] = { 1,2,3,4,5,6,7,8,9,10 };
//
//	printf("%p\n", arr);
//	printf("%p\n", &i);
//
//	/*for (i = 0; i <= 12; i++)
//	{
//		arr[i] = 0;
//		printf("hehe\n");
//	}*/
//
//	return 0;
//}
//


//int main()
//{
//	while (1)
//	{
//		printf("hehe\n");
//	}
//
//	return 0;
//}
//

//第一个void 表示函数不会返回值
//第二个void 表示函数不需要传任何参数
//void test(void)
//{
//	printf("hehe\n");
//}
//
//int main()
//{
//	test();
//	return 0;
//}

//void* q;
//int* p;

//数值有不同表示形式
//2进制
//8进制
//10进制
//16进制
//十进制的21
//0b10101
// 
//025
// 
//21
// 
//0x15
//

//
//整数的2进制表示也有三种表示形式：
// 1. 正的整数，原码、反码、补码相同
// 2. 负的整数，原码、反码、补码是需要计算的
//原码：直接通过正负的形式写出的二进制序列就是原码
//反码：原码的符号位不变，其他位按位取反得到的就是反码
//补码：反码+1就是补码
//整数内存中存放是补码的二进制序列
//
//
//int main()
//{
//	int a = 20;
//	//20
//	//00000000000000000000000000010100
//	//0x00 00 00 14
//	//00000000000000000000000000010100
//	//00000000000000000000000000010100
//	//
//	int b = -10;
//	//10000000000000000000000000001010--原码
//	//0x80 00 00 0a
//	//11111111111111111111111111110101--反码
//	//0xfffffff5
//	//11111111111111111111111111110110--补码
//	//0xfffffff6
//	//
//	return 0;
//}



//int check_sys()
//{
//	int a = 1;
//	if (*(char*)&a == 1)
//	{
//		return 1;//小端
//	}
//	else
//	{
//		return 0;//大端
//	}
//}
//
//int check_sys()
//{
//	int a = 1;
//	return *(char*)&a;
//}
//
//int main()
//{
//	//printf("小端\n");//err
//
//	int ret = check_sys();
//	if (ret == 1)
//		printf("小端\n");
//	else
//		printf("大端\n");
//
//	return 0;
//}
//

#include <stdio.h>

//int main()
//{
//	char a = -1;
//	signed char b = -1;
//	unsigned char c = -1;
//
//	printf("a=%d,b=%d,c=%d", a, b, c);
//	
//	return 0;
//}
//


#include <stdio.h>
//
//int main()
//{
//	//char -128~127
//	char a = -128;
//
//	//10000000000000000000000010000000
//	//11111111111111111111111101111111
//	//11111111111111111111111110000000 - 截断
//	//10000000 - a
//	//11111111111111111111111110000000 - 提升
//	//
//	printf("%u\n", a);
//	printf("%d\n", a);
//	//11111111111111111111111110000000
//	//10000000000000000000000001111111
//	//10000000000000000000000010000000
//	//-128
//
//	//
//	//
//	//%u - 打印无符号整数
//	//
//	return 0;
//}
//

//#include <stdio.h>
//int main()
//{
//	//-128~127
//	char a = 128;
//	//00000000000000000000000010000000
//	//10000000 - a
//	printf("%u\n", a);
//	printf("%d\n", a);//-128
//
//	//10000000
//	//11111111111111111111111110000000
//	//10000000000000000000000001111111
//	//10000000000000000000000010000000
//
//	return 0;
//}
//

//
//int main()
//{
//	int i = -20;
//	//10000000000000000000000000010100
//	//11111111111111111111111111101011
//	//11111111111111111111111111101100 - -20的补码
//	//
//	unsigned int j = 10;
//	//00000000000000000000000000001010
//	printf("%d\n", i + j);
//	//11111111111111111111111111101100
//	//00000000000000000000000000001010
//	//11111111111111111111111111110110 - 补码
//	//10000000000000000000000000001001
//	//10000000000000000000000000001010 -> -10
//	//
//	return 0;
//}
//
//








