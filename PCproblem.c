#include<stdio.h>
#include<pthread.h>

#define MAX 10             	//产品最大数量

pthread_mutex_t the_mutex;
pthread_cond_t condc,condp;
int buffer=0;               //产品缓冲区
int total=0;

void *producer(void *ptr)
{
    int i=1;
    while(total<50)
    {
        pthread_mutex_lock(&the_mutex);
        printf("生产者%lu第%d次使用缓冲区\n",pthread_self(),i);
        while(buffer==MAX&&total<50)
        {
            printf("生产者%lu等待消费者消费\n",pthread_self());
            pthread_cond_wait(&condp,&the_mutex);
        }
        buffer++;
        printf("%d\n",buffer);
        pthread_cond_broadcast(&condc);        //唤醒消费者
        pthread_mutex_unlock(&the_mutex);
        printf("生产者%lu第%d次释放缓冲区\n",pthread_self(),i);
		i++;
    }
    pthread_exit(0);
}

void *consumer(void *ptr)
{
    int i=1;
    while(total<50)
    {
        pthread_mutex_lock(&the_mutex);
        printf("消费者%lu第%d次使用缓冲区\n",pthread_self(),i);
        while(buffer==0&&total<50)
        {
            printf("消费者%lu等待生产者生产\n",pthread_self());
            pthread_cond_wait(&condc,&the_mutex);
        }
        buffer--;
		total++;
        printf("%d\n",buffer);
        pthread_cond_broadcast(&condp);        //唤醒生产者
        pthread_mutex_unlock(&the_mutex);
        printf("消费者%lu第%d次释放缓冲区\n",pthread_self(),i);
		i++;
    }
	pthread_cond_broadcast(&condp);        //唤醒生产者
    pthread_exit(0);
}

int main()
{
    pthread_t pro1,pro2,pro3,con1,con2;
    pthread_mutex_init(&the_mutex,0);
    pthread_cond_init(&condc,0);
    pthread_cond_init(&condp,0);
	pthread_create(&pro1,0,producer,0);
	pthread_create(&pro2,0,producer,0);
	pthread_create(&pro3,0,producer,0);
    pthread_create(&con1,0,consumer,0);
	pthread_create(&con2,0,consumer,0);
    pthread_join(pro1,0);
	pthread_join(pro2,0);
	pthread_join(pro3,0);
    pthread_join(con1,0);
	pthread_join(con2,0);
    pthread_cond_destroy(&condc);
    pthread_cond_destroy(&condp);
    pthread_mutex_destroy(&the_mutex);
	return 0;
}
