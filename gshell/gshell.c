#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <string.h>
#include <fcntl.h>

#define MAX 100
#define LEN 100

//shell指令中单个管道结构体
struct cmdList{
    int argc;   //参数个数
    char* argv[MAX];
};

struct cmdList* cmdv[MAX];  //shell指令
int num=0;    //管道个数
int backFlag=0;   //标记是否为后台处理命令

//执行外部命令
void execute(char* argv[])
{
    int error;
    error=execvp(argv[0],argv);
    if(error==-1)
    {
        printf("Failed!\n");
    }
    exit(1);
}

//切分单个管道的参数
void splitCmd(char* line)
{
    struct cmdList* cmd=(struct cmdList*)malloc(sizeof(struct cmdList));
    cmdv[num++]=cmd;
    cmd->argc=0;
    char* save;
    char* arg=strtok_r(line," \t",&save);   //切分空格
    while(arg)
    {
        cmd->argv[cmd->argc]=arg;
        arg=strtok_r(NULL," \t",&save);
        cmd->argc++;
    }
    cmd->argv[cmd->argc]=NULL;  //标记参数结束
}

//切分管道
void splitPipe(char* line)
{
    char* save;
    char* cmd=strtok_r(line,"|",&save);
    while(cmd)
    {
        splitCmd(cmd);
        cmd=strtok_r(NULL,"|",&save);
    }
}

//执行管道命令
void doPipe(int index)
{
    if(index==num-1)
    {
        execute(cmdv[index]->argv);
    }
    int fd[2];  //文件描述符，0读1写
    pipe(fd);   //创建管道
    if(fork()==0)
    {
        dup2(fd[1],1);  //替换标准输出
        close(fd[0]);
        close(fd[1]);
        execute(cmdv[index]->argv);
    }
    dup2(fd[0],0);  //替换标准输入
    close(fd[0]);
    close(fd[1]);
    doPipe(index+1);
}

//执行内部指令
int inner(char* line)
{
    char *save,*innerCmd[MAX];
    char *arg=strtok_r(line," \t",&save);
    int i=0;    //记录参数个数
    while(arg)
    {
        innerCmd[i]=arg;
        i++;
        arg=strtok_r(NULL," \t",&save);
    }
    innerCmd[i]=NULL;   //标记参数结束
    if(strcmp(innerCmd[i-1],"&")==0)    //判断是否为后台处理命令
    {
        backFlag=1;
        i--;
    }
    if(strcmp(innerCmd[0],"cd")==0)
    {
        char buf[LEN];
        if(chdir(innerCmd[1])!=-1)  //改变当前工作目录
        {
            getcwd(buf,sizeof(buf));    //获取当前工作目录的绝对路径
            printf("Current dir is: %s\n",buf);
        }
        else
        {
            printf("Bad path!\n");
        }
        return 1;
    }
    else if(strcmp(innerCmd[0],"pwd")==0)
    {
        char buf[LEN];
        getcwd(buf,sizeof(buf));
        printf("Current dir is: %s\n",buf);
        return 1;
    }
    else if(strcmp(innerCmd[0],"exit")==0)
    {
        exit(0);
        return 1;
    } else
        return 0;
}

//输入重定向
void catIn(char *line)
{
    char temp[LEN];
    int fd;
    if(line[0]=='<')
    {
        strcpy(temp,line+1);
        fd=open(temp,O_RDONLY);
        cmdv[0]->argv[cmdv[0]->argc-1]=NULL;  //默认重定向为参数的最后一个，差；重新标记参数结尾
        cmdv[0]->argc--;
        if(fd==-1)
        {
            printf("File open failed!\n");
            return;
        }
        dup2(fd,0);
        close(fd);
    }
}

//输出重定向
void catOut(char *line)
{
    char temp[LEN];
    int fd;
    if(line[0]=='>')
    {
        strcpy(temp,line+1);
        fd=open(temp,O_CREAT|O_RDWR,0666);  //0666为权限
        cmdv[num-1]->argv[cmdv[num-1]->argc-1]=NULL;  //默认重定向为参数的最后一个，差；重新标记参数结尾
        cmdv[num-1]->argc--;
        if(fd==-1)
        {
            printf("File open failed!\n");
            return;
        }
        dup2(fd,1);
        close(fd);
    }
}

int main()
{
    int pid;
    char buf[LEN],line[LEN];
    while (1)
    {
        fgets(buf,LEN,stdin);   //读入shell指令
        if(buf[0]=='\n') continue;
        buf[strlen(buf)-1]='\0';
        strcpy(line,buf);
        int innerFlag;  //标记内部指令
        innerFlag=inner(buf);
        if(innerFlag==0)
        {
            pid=fork();
            if(pid==0)
            {
                splitPipe(line);
                //如果是后台命令则将&删除
                if(strcmp(cmdv[num-1]->argv[cmdv[num-1]->argc-1],"&")==0)
                {
                    cmdv[num-1]->argc--;
                    cmdv[num-1]->argv[cmdv[num-1]->argc-1]=NULL;
                }
                if(cmdv[0]->argv[cmdv[0]->argc-1]!=NULL)
                {
                    char temp[LEN];
                    strcpy(temp,cmdv[0]->argv[cmdv[0]->argc-1]);
                    catIn(temp);
                }
                if(cmdv[num-1]->argv[cmdv[num-1]->argc-1]!=NULL)
                {
                    char temp[LEN];
                    strcpy(temp,cmdv[num-1]->argv[cmdv[num-1]->argc-1]);
                    catOut(temp);
                }
                doPipe(0);
                exit(0);
            }
            if(backFlag==0)     //非后台处理命令主进程才等待
            {
                waitpid(pid,NULL,0);
            }
        }
    }
    return 0;
}

