#define _CRT_SECURE_NO_WARNINGS 1
#include <stdio.h>
//
//struct S
//{
//	int n;
//	int arr[];//���������Ա
//};
//
//int main()
//{
//	//int sz = sizeof(struct S);
//	//printf("%d\n", sz);
//	//struct S s;//4
//
//	//���������ʹ��
//	struct S* ps = (struct S*)malloc(sizeof(struct S) + 40);
//	if (ps == NULL)
//	{
//		//....
//		return 1;
//	}
//	ps->n = 100;
//	int i = 0;
//	for (i = 0; i < 10; i++)
//	{
//		ps->arr[i] = i;
//	}
//	for (i = 0; i < 10; i++)
//	{
//		printf("%d ", ps->arr[i]);
//	}
//	struct S* ptr = (struct S*)realloc(ps, sizeof(struct S)+80);
//	if (ptr != NULL)
//	{
//		ps = ptr;
//		ptr = NULL;
//	}
//	//...
//	//�ͷ�
//	free(ps);
//	ps = NULL;
//
//	return 0;
//}


struct S
{
	int n;
	int* arr;
};

int main()
{
	struct S*ps = (struct S*)malloc(sizeof(struct S));
	if (ps == NULL)
	{
		return 1;
	}
	ps->n = 100;
	ps->arr = (int*)malloc(40);
	if (ps->arr == NULL)
	{
		//....
		return 1;
	}
	//ʹ��
	int i = 0;
	for (i = 0; i < 10; i++)
	{
		ps->arr[i] = i;
	}
	for (i = 0; i < 10; i++)
	{
		printf("%d ", ps->arr[i]);
	}

	//����
	int*ptr = (int*)realloc(ps->arr, 80);
	if (ptr == NULL)
	{
		return 1;
	}
	else
	{  
		ps->arr = ptr;//���䣺������ݳɹ�������Ҫ��ptr��ֵ��ֵ��ps->arr���ռ���Ȼ��ps->arrά��
	}
	//ʹ��
	
	//�ͷ�
	free(ps->arr);
	free(ps);
	ps = NULL;

	return 0;
}



//FILE
#include <string.h>
#include <errno.h>
//
//int main()
//{
//	FILE* pf = fopen("C:\\Users\\zpeng\\Desktop\\test.txt", "r");
//	if (pf == NULL)
//	{
//		printf("%s\n", strerror(errno));
//		return 1;
//	}
//	//...
//	//���ļ�
//
//	//�ر��ļ�
//	fclose(pf);
//	pf = NULL;
//
//	return 0;
//}

//дһ���ַ�
//
//int main()
//{
//	FILE* pf = fopen("test.txt", "w");
//	if (pf == NULL)
//	{
//		printf("%s\n", strerror(errno));
//		return 1;
//	}
//	//д�ļ�
//	char i = 0;
//	for (i = 'a'; i <= 'z'; i++)
//	{
//		fputc(i, pf);
//	}
//	//�ر��ļ�
//	fclose(pf);
//	pf = NULL;
//
//	return 0;
//}

//���ַ�
//
//int main()
//{
//	FILE* pf = fopen("test.txt", "r");
//	if (pf == NULL)
//	{
//		printf("%s\n", strerror(errno));
//		return 1;
//	}
//	//���ļ�
//	//int ch = fgetc(pf);
//	//printf("%c\n", ch);
//	//ch = fgetc(pf);
//	//printf("%c\n", ch);
//	//ch = fgetc(pf);
//	//printf("%c\n", ch);
//	//ch = fgetc(pf);
//	//printf("%c\n", ch);
//	int ch = 0;
//	while ((ch = fgetc(pf)) != EOF)
//	{
//		printf("%c ", ch);
//	}
//
//	//�ر��ļ�
//	fclose(pf);
//	pf = NULL;
//
//	return 0;
//}


//дһ������
//int main()
//{
//	FILE* pf = fopen("test.txt", "w");
//	if (pf == NULL)
//	{
//		printf("%s\n", strerror(errno));
//		return 1;
//	}
//
//	//дһ������
//	fputs("hello bit\n", pf);
//	fputs("hello bit\n", pf);
//
//
//	//�ر��ļ�
//	fclose(pf);
//	pf = NULL;
//
//	return 0;
//}

//int main()
//{
//	FILE* pf = fopen("test.txt", "r");
//	if (pf == NULL)
//	{
//		//printf("%s\n", strerror(errno));
//		perror("fopen");
//		return 1;
//	}
//
//	//��һ������
//	char arr[20];
//	fgets(arr, 20, pf);
//	
//	printf("%s\n", arr);
//
//	//�ر��ļ�
//	fclose(pf);
//	pf = NULL;
//
//	return 0;
//}
//
//struct S
//{
//	char arr[10];
//	int age;
//	float score;
//};
//
//int main()
//{
//	struct S s = {0};
//
//	FILE* pf = fopen("test.txt", "r");
//	if (pf == NULL)
//	{
//		perror("fopen");
//		return 1;
//	}
//	//
//	fscanf(pf, "%s %d %f", s.arr, &(s.age), &(s.score));
//	//printf("%s %d %f\n", s.arr, s.age, s.score);
//	fprintf(stdout, "%s %d %f\n", s.arr, s.age, s.score);
//
//	fclose(pf);
//	pf = NULL;
//	return 0;
//}
//
//
//int main()
//{
//	struct S s = { "zhangsan", 25, 50.5f };
//
//	FILE*pf = fopen("test.txt", "w");
//	if (pf == NULL)
//	{
//		perror("fopen");
//		return 1;
//	}
//	//
//	fprintf(pf, "%s %d %f", s.arr, s.age, s.score);
//
//	fclose(pf);
//	pf = NULL;
//	return 0;
//}

//
//��
//FILE*
//
//printf
//scanf
//
//�κ�һ��C����ֻҪ���������ͻ�Ĭ�ϴ�3������
//FILE* stdin - ��׼�����������̣� 
//FILE* stdout - ��׼���������Ļ��
//FILE* stderr - ��׼����������Ļ��
//



//struct S
//{
//	char arr[10];
//	int age;
//	float score;
//};

//
//int main()
//{
//	struct S s = { 0 };
//	//�Զ����Ƶ���ʽд���ļ���
//	FILE* pf = fopen("test.txt", "rb");
//	if (pf == NULL)
//	{
//		perror("fopen");
//		return 1;
//	}
//	//�����Ƶķ�ʽ��
//	fread(&s, sizeof(struct S), 1, pf);
//	printf("%s %d %f\n", s.arr, s.age, s.score);
//
//	fclose(pf);
//	pf = NULL;
//	return 0;
//}

//int main()
//{
//	struct S s = { "zhangsan", 25, 50.5f };
//	//�Զ����Ƶ���ʽд���ļ���
//	FILE* pf = fopen("test.txt", "wb");
//	if (pf == NULL)
//	{
//		perror("fopen");
//		return 1;
//	}
//	//�����Ƶķ�ʽд
//	fwrite(&s, sizeof(struct S), 1, pf);
//
//	fclose(pf);
//	pf = NULL;
//	return 0;
//}

//
//struct S
//{
//	char arr[10];
//	int age;
//	float score;
//};
//
//int main()
//{
//	struct S s = { "zhangsan", 20, 55.5f };
//	struct S tmp = { 0 };
//	char buf[100] = { 0 };
//	//��s�еĸ�ʽ������ת�����ַ����ŵ�buf��
//	sprintf(buf, "%s %d %f", s.arr, s.age, s.score);
//
//	//"zhangsan 20 55.500000";
//	printf("�ַ�����%s\n", buf);
//
//	//���ַ���buf�л�ȡһ����ʽ�������ݵ�tmp��
//	sscanf(buf, "%s %d %f", tmp.arr, &(tmp.age), &(tmp.score));
//	printf("��ʽ����%s %d %f\n", tmp.arr, tmp.age, tmp.score);
//	return 0;
//}
//


//���ַ�
//
//int main()
//{
//	FILE* pf = fopen("test.txt", "r");
//	if (pf == NULL)
//	{
//		printf("%s\n", strerror(errno));
//		return 1;
//	}
//	//���ļ�
//	//��λ�ļ�ָ��
//	fseek(pf, 2, SEEK_SET);
//	int ch = fgetc(pf);//c
//	printf("%c\n", ch);
//	printf("%d\n", ftell(pf));//3
//
//	//fseek(pf, 2, SEEK_CUR);
//	fseek(pf, -1, SEEK_END);
//	ch = fgetc(pf);//f
//	printf("%c\n", ch);	
//	printf("%d\n", ftell(pf));//6
//
//	rewind(pf);
//	ch = fgetc(pf);//a
//	printf("%c\n", ch);
//
//	//�ر��ļ�
//	fclose(pf);
//	pf = NULL;
//	
//
//	return 0;
//}
