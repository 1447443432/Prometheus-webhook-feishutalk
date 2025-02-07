### 1、飞书配置
- app_id 和 app_secret

![secret](staticfiles/fieshu_secret.png)

- 权限

> drive:file:upload
>
> im:resource

![权限](staticfiles/fieshu_quanxian.png)

### 2、程序中修改项

- Prom_Feishu.py修改 飞书机器人webhook地址

> self.webhook 值改为 实际的飞书机器人webhook地址

- default.conf

```bash
Server:
  listen: 0.0.0.0
  port: 5000

Prometheus:
  url: http://192.168.0.2:9090

Grafana:
  url: http://192.168.0.2:8082
  id: "9CWBz0bik"
  token: "Bearer glsa_yocMv8CVUq2utkhje4NCwipeLMTMqYiw_4d8b181f"
  pict_path: /tmp/

Feishu:
  app_id: "cli_a72ef520fefb100e"
  app_secret: "HRuf3RCESzw7DzzzKbOlFgySk7YHnUDk"
```

### 3、Prometheus + grafana中修改项

- prometheus

> panel_id的获取方式: 点击进入Grafana的一个监控面板, 所属url的最后一位。

![panel_id的获取方式](staticfiles/panel_id的获取方式.png)

```bash
[root@huoshan-jing prometheus]# cat config/rules/host.yml 
groups:
     
# CPU 使用率持续 3m 达到 90% 及以上
- name: HostCPU
  rules:
  - alert: CPU使用率较高
    expr: 100 * (1 - avg(irate(node_cpu_seconds_total{mode="idle"}[2m])) by (instance)) > 0
    for: 3m
    labels:
      level: Warning
      panel_id: 7
    annotations:
      description: "服务器CPU当前使用率较高,当前使用率: {{ $value | printf \"%.2f\" }}%"

# 内存使用率持续 3m 达到 90% 及以上
- name: HostMEM
  rules:
  - alert: 内存使用率较高
    expr: (1 - (node_memory_MemAvailable_bytes / (node_memory_MemTotal_bytes)))* 100 > 1
    for: 3m
    labels:
      level: Warning
      panel_id: 156
    annotations:
      description: "服务器内存当前使用率较高,当前使用率: {{ $value | printf \"%.2f\" }}%"

# / 与 /data 目录使用率持续 3m 达到 90% 及以上
- name: Disk
  rules:
  - alert: 磁盘使用率较高
    expr: 100 * ((node_filesystem_size_bytes{fstype=~"xfs|ext4"} - node_filesystem_avail_bytes) / node_filesystem_size_bytes {mountpoint=~"/|/data"}) > 1
    for: 3m
    labels:
      level: Warning
      panel_id: 174
    annotations:
      description: "挂载点: {{$labels.mountpoint}}, 使用率: {{ $value | printf \"%.2f\" }}%"
[root@huoshan-jing prometheus]#
```



- grafana

> grafana需安装grafana-image-renderer插件

```bash
cat > docker-compose.yaml << 'EOF'
version: '3'
 
networks:
  prometheus:
    driver: bridge
 
services:
  prometheus:
    #image: prom/prometheus
    image: registry.cn-shanghai.aliyuncs.com/jing-images/prometheus:v2.32.1
    container_name: prometheus
    hostname: prometheus
    restart: always
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml
      - ./config/rules:/etc/prometheus/rules
      - ./data/prometheus:/prometheus
      - /usr/share/zoneinfo/Etc/GMT-8:/etc/localtime
    ports:
      - "9090:9090"
    networks:
      - prometheus
 
  grafana:
    #image: grafana/grafana
    image: registry.cn-shanghai.aliyuncs.com/jing-images/grafana:10.1.1
    container_name: grafana
    hostname: grafana
    restart: always
    ports:
      - "8082:3000"
    volumes:
      - ./data/grafana:/var/lib/grafana
      #- ./config/plugins:/var/lib/grafana/plugins
      - /usr/share/zoneinfo/Etc/GMT-8:/etc/localtime
    networks:
      - prometheus
    environment:
      GF_RENDERING_SERVER_URL: http://renderer:8081/render
      GF_RENDERING_CALLBACK_URL: http://grafana:3000/
      GF_LOG_FILTERS: rendering:debug
  renderer:
    #image: grafana/grafana-image-renderer:latest
    image: registry.cn-shanghai.aliyuncs.com/jing-images/grafana-image-renderer
    ports:
      - 8081
    networks:
      - prometheus
EOF

```





