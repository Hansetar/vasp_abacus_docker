# vasp_abacus_docker
vasp install script 一键安装脚本，
由于网络问题，镜像无法上传至docker，若有兴趣者，可以帮忙上传一下，别忘了附一下链接，万分感谢

由于镜像过大，和网络原因，上传dockerhub失败，并且github的actions的磁盘容量不够，没法利用这个编译推送（至少得60G的磁盘容量）

所以是在本地编译出docker镜像，并且上传到百度网盘中（[下载链接]()） 提取码：
百度链接：



## 部署



## 导入docker镜像

编译docker镜像
```
docker load < han_sci_cal.tar
```

将会得到镜像，使用`docker images`可以看到如下
```shell
#docker images
REPOSITORY      TAG       IMAGE ID       CREATED        SIZE
han/sci_cal     01        2a4bec6fef9e   47 hours ago   28.8GB
```

启动docker容器
```shell
docker run -it \
    --name=sciwork \
    -v LDA_PATH:/vasp/pot/LDA\
    -v PBE_PATH:/vasp/pot/PBE \
    -v PBE_PATH:/vasp/pot/PBE \
    -v your_work_dir:/work \
    han/sci_cal:01
```


## 使用
```
docker exec -it sciwork bash
```

## 其他

涉及推荐路径

包含工具

vasp_6.4.2

abacus_3.8.2

vaspkit_1.3.5

atomkit_0.9.0


工作路径建议：/work

赝势库自行下载

建议将vasp的赝势库

分别映射或者复制（需要自行建立文件夹）到`/vasp/pot/LDA`  `/vasp/pot/PBE` `/vasp/pot/PBE` 可以直接被vaspkit调用，默认为PEB赝势



如有条件者，可以上传至dockerhub，上传同时请附上链接
