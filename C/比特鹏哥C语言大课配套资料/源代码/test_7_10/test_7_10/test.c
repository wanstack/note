#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
#include <string.h>

//ʵ��һ�����������������ַ����е�k���ַ���
//void left_rotate(char arr[], int k)
//{
//	int i = 0;
//	int len = strlen(arr);
//	k %= len;
//	for (i = 0; i < k; i++)
//	{
//		//��ת1���ַ�
//		//1
//		char tmp = arr[0];
//		//2
//		int j = 0;
//		for (j = 0; j < len - 1; j++)
//		{
//			arr[j] = arr[j + 1];
//		}
//		//3
//		arr[len - 1] = tmp;
//	}
//}
//
//#include <assert.h>
//
//void reverse(char* left, char* right)
//{
//	assert(left && right);
//	while (left < right)
//	{
//		char tmp = *left;
//		*left = *right;
//		*right = tmp;
//		left++;
//		right--;
//	}
//}
//
//void left_rotate(char arr[], int k)
//{
//	int len = strlen(arr);
//	k%=len;
//	reverse(arr, arr+k-1);//��
//	reverse(arr+k, arr+len-1);//��
//	reverse(arr, arr + len-1);//��
//}
//
//int main()
//{
//	char arr[] = "abcdef";//cdefab
//	int k = 0;
//	scanf("%d", &k);//2
//	left_rotate(arr, k);
//	printf("%s\n", arr);
//
//	return 0;
//}


//���Ͼ���
//��һ�����־��󣬾����ÿ�д������ǵ����ģ�������ϵ����ǵ����ģ�
//���д�����������ľ����в���ĳ�������Ƿ���ڡ�
//Ҫ��ʱ�临�Ӷ�С��O(N);

//1 2 3
//4 5 6
//7 8 9
//N

//int find_num(int arr[3][3], int r, int c, int k)
//{
//	int x = 0;
//	int y = c - 1;
//	while (x<=r-1 && y>=0)
//	{
//		if (k < arr[x][y])
//		{
//			y--;
//		}
//		else if (k > arr[x][y])
//		{
//			x++;
//		}
//		else
//		{
//			return 1;
//		}
//	}
//	return 0;//�Ҳ���
//}
//
//struct Point
//{
//	int x;
//	int y;
//};
//
//struct Point find_num(int arr[3][3], int r, int c, int k)
//{
//	int x = 0;
//	int y = c - 1;
//	struct Point p = { -1, -1 };
//	while (x <= r - 1 && y >= 0)
//	{
//		if (k < arr[x][y])
//		{
//			y--;
//		}
//		else if (k > arr[x][y])
//		{
//			x++;
//		}
//		else
//		{
//			p.x = x;
//			p.y = y;
//			return p;
//		}
//	}
//	return p;//�Ҳ���
//}
//
//int main()
//{
//	int arr[3][3] = { 1,2,3,4,5,6,7,8,9 };
//	int k = 0;
//	scanf("%d", &k);
//	struct Point ret = find_num(arr, 3, 3, k);
//	printf("%d %d\n", ret.x, ret.y);
//	return 0;
//}


//
//�����Ͳ���
//
//int find_num(int arr[3][3], int *px, int*py, int k)
//{
//	int x = 0;
//	int y = *py - 1;
//	while (x <= *px - 1 && y >= 0)
//	{
//		if (k < arr[x][y])
//		{
//			y--;
//		}
//		else if (k > arr[x][y])
//		{
//			x++;
//		}
//		else
//		{
//			*px = x;
//			*py = y;
//			return 1;
//		}
//	}
//	*px = -1;
//	*py = -1;
//	return 0;//�Ҳ���
//}
//
//int main()
//{
//	int arr[3][3] = { 1,2,3,4,5,6,7,8,9 };
//	int k = 0;
//	scanf("%d", &k);
//	int a = 3;//��
//	int b = 3;//��
//	int ret = find_num(arr, &a, &b, k);
//	if (ret == 1)
//		printf("%d %d\n", a, b);
//	else
//		printf("�Ҳ���\n");
//
//
//	scanf("%d", &k);
//	a = 3;
//	b = 3;
//	ret = find_num(arr, &a, &b, k);
//	if (ret == 1)
//		printf("%d %d\n", a, b);
//	else
//		printf("�Ҳ���\n");
//	return 0;
//}
//

//
//int is_left_move(char arr1[], char arr2[])
//{
//	int len = strlen(arr1);
//	int i = 0;
//	for (i = 0; i < len; i++)
//	{
//		char tmp = arr1[0];
//		int j = 0;
//		for (j = 0; j < len - 1; j++)
//		{
//			arr1[j] = arr1[j + 1];
//		}
//		arr1[len - 1] = tmp;
//		
//		if (strcmp(arr2, arr1) == 0)
//			return 1;
//	}
//	return 0;
//}
//
//int main()
//{
//	char arr1[] = "abcdef";
//	//bcdefa
//	//cdefab
//	//defabc
//	//efabcd
//	//fabcde
//	//abcdef
//	char arr2[] = "cdefab";
//	//�ж�arr2�е��ַ����Ƿ����ͨ��arr1�е��ַ�����ת�õ�
//	int ret = is_left_move(arr1, arr2);
//	if (ret == 1)
//		printf("ok\n");
//	else
//		printf("No\n");
//
//	return 0;
//}

//
//int is_left_move(char arr1[], char arr2[])
//{
//	int len1 = strlen(arr1);
//	int len2 = strlen(arr2);
//	if (len1 != len2)
//		return 0;
//
//	strncat(arr1, arr1, len1);
//	char* ret = strstr(arr1, arr2);
//	if(ret == NULL)
//		return 0;
//	else
//		return 1;
//}
//
//int main()
//{
//	char arr1[20] = "abcdef";
//	//abcdefabcdef
//	//bcdefa
//	//cdefab
//	//defabc
//	//efabcd
//	//fabcde
//	//abcdef
//	char arr2[] = "cdefab";
//	int ret = is_left_move(arr1, arr2);
//	if (ret == 1)
//		printf("ok\n");
//	else
//		printf("No\n");
//
//	return 0;
//}
//
//
//#include <stdio.h>
//int main()
//{
//    int n = 0;
//    int m = 0;
//    scanf("%d%d", &n, &m);
//    //int arr[n][m];//C99�еı䳤����
//    int arr[10][10] = { 0 };
//    int i = 0;
//    int j = 0;
//    //����
//    for (i = 0; i < n; i++)
//    {
//        for (j = 0; j < m; j++)
//        {
//            scanf("%d", &arr[i][j]);
//        }
//    }
//    //���
//    //��
//    for (i = 0; i < m; i++)
//    {
//        //��
//        for (j = 0; j < n; j++)
//        {
//            printf("%d ", arr[j][i]);
//        }
//        printf("\n");
//    }
//    return 0;
//}
//
//#include <stdio.h>
//
//int main()
//{
//    int n = 0;
//    scanf("%d", &n);
//    //int arr[n][n];
//    int arr[10][10];
//    int i = 0;
//    int j = 0;
//    int flag = 1;//�������Ǿ���
//    for (i = 0; i < n; i++)
//    {
//        for (j = 0; j < n; j++)
//        {
//            scanf("%d", &arr[i][j]);
//        }
//    }
//    //�ж�
//    for (i = 0; i < n; i++)
//    {
//        for (j = 0; j < i; j++)
//        {
//            if (arr[i][j] != 0)
//            {
//                flag = 0;//���������Ǿ���
//                goto end;
//            }
//        }
//    }
//end:
//    if (flag == 0)
//        printf("NO\n");
//    else
//        printf("YES\n");
//    return 0;
//}
//
//#include <stdio.h>
//int main()
//{
//    int n = 0;
//    int arr[50] = { 0 };
//    scanf("%d", &n);
//    int i = 0;
//    int flag1 = 0;
//    int flag2 = 0;
//    for (i = 0; i < n; i++)
//    {
//        scanf("%d", &arr[i]);
//        if (i > 0)
//        {
//            if (arr[i] > arr[i - 1])
//            {
//                flag1 = 1;
//            }
//            else if (arr[i] < arr[i - 1])
//            {
//                flag2 = 1;
//            }
//            else
//            {
//                ;
//            }
//        }
//    }
//    if (flag1 + flag2 <= 1)
//        printf("sorted\n");
//    else
//        printf("unsorted\n");
//    return 0;
//}
//

//�ṹ�����͵Ķ���

//ѧ��

//struct Stu
//{
//	//ѧ�����������
//	char name[20];
//	int age;
//};

//struct Stu
//{
//	//ѧ�����������
//	char name[20];
//	int age;
//} s1,s2;//s1,s2��ȫ�ֱ���
//
//
//int main()
//{
//	struct Stu s3;//s3�Ǿֲ�����
//
//	return 0;
//}


//�����ṹ������
//ֻ��ʹ��һ��

//struct
//{
//	//ѧ�����������
//	char name[20];
//	int age;
//}s1;
//
//int main()
//{
//	return 0;
//}
//


//struct
//{
//	int a;
//	char b;
//	float c;
//} x;
//
//struct
//{
//	int a;
//	char b;
//	float c;
//}a[20], * p;
//
//int main()
//{
//	p = &x;
//	return 0;
//}


//err
//struct Node
//{
//	int data;//4
//	struct Node next;
//};
//
//
//int main()
//{
//	sizeof(struct Node);
//	return 0;
//}
//1
//typedef struct Node
//{
//	int data;
//	struct Node* next;
//}* linklist;
//
////2
//struct Node
//{
//	int data;
//	struct Node* next;
//};
//typedef struct Node* linklist;

struct Point
{
	int x;
	int y;
}p1 = {2,3};

struct score
{
	int n;
	char ch;
};

struct Stu
{
	char name[20];
	int age;
	struct score s;
};

int main()
{
	struct Point p2 = { 3,4 };
	struct Stu s1 = { "zhangsan", 20 , {100, 'q'}};
	printf("%s %d %d %c\n", s1.name, s1.age, s1.s.n, s1.s.ch);
	return 0;
}
