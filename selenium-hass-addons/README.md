# selenium_electricity

Fork from https://github.com/louisslee/sgcc_electricity (感谢作者）

## 本 addon 方式
ha的加载项仓库(Repo)添加：https://github.com/dscao/hassio-addons \
镜像占用1.16G，请保证足够空间。

##  v1.5.2 更新日志
修复8月份后数据抓取数据出错的问题

##  v1.5 更新日志
1. 修复1月份无年度用电数据抓取数据出错的问题
2. 增加电量数据的最后日期

## v1.4 更新日志
增加本月用电量属性、欠费金额属性 

## v1.3 更新日志
增加电费属性 是否结清 

------以下为原项目内容-----

## v1.1 更新日志

1.适配多个户号（多个户号相关的实体名称、UI配置（如需），见使用说明）

2.增加查看年用电量、电费

3.优化部分已知bug

---------------------------------

## 升级指引

### 1. addon 部署

然后在webUI上点击配置-》加载项-》加载项商店，如果有升级会显示，直接点击升级即可；如果没有的话，右上角点击检查更新一下。


### 2. docker 部署

输入以下命令，从github上拉取镜像

```bash
docker pull dscao/sgcc_electricity
```

---------------------------------

## 使用说明

本应用可以帮助你将国网的电费、用电量数据接入HA，适用于除南方电网覆盖省份外的用户。即除广东、广西、云南、贵州、海南等省份的用户外，均可使用本应用获取电力、电费数据。

本应用每12小时抓取一次数据，并在HA里更新以下四个实体

```
sensor.last_electricity_usage：最近一天用电量
sensor.electricity_charge_balance：电费余额
sensor.yearly_electricity_usage： 今年以来用电量
sensor.yearly_electricity_charge: 今年以来电费
```

__注：如果你有一个户号，在HA里就是以上实体名；如果你有多个户号，实体名称还要加 “\_户号”后缀，举例:sensor.last_electricity_usage_1234567890__


由于采用REST API方式创建sensor，没有做实体注册，无法在webui里编辑。如果需要，你可以在configuration.yaml下增加如下配置后重启HA，这样你就可在webUI编辑对应的实体了。


如果你有一个户号，参照以下配置

```yaml
template:
  - trigger:
      - platform: event
        event_type: "state_changed"
        event_data: 
          entity_id: sensor.electricity_95598
    sensor:
      - name: electricity_charge_balance_entity
        unique_id: electricity_charge_balance_entity
        state: "{{ states('sensor.electricity_95598') }}"
        unit_of_measurement: "CNY"
        device_class: monetary

      - name: electricity_balance_is_pay_entity
        unique_id: electricity_balance_is_pay_entity
        state: "{{ state_attr('sensor.electricity_95598', 'is_pay') }}"
 
      - name: last_electricity_usage_entity
        unique_id: last_electricity_usage_entity
        state: "{{ state_attr('sensor.electricity_95598', 'last_electricity_usage') }}"
        state_class: measurement
        unit_of_measurement: "kWh"

      - name: yearly_electricity_usage_entity
        unique_id: yearly_electricity_usage_entity
        state: "{{ state_attr('sensor.electricity_95598', 'yearly_electricity_usage') }}"
        state_class: measurement
        unit_of_measurement: "kWh"

      - name: yearly_electricity_charge_entity
        unique_id: yearly_electricity_charge_entity
        state: "{{ state_attr('sensor.electricity_95598', 'yearly_electricity_charge') }}"
        unit_of_measurement: "CNY"
        device_class: monetary
        
      - name: electricity_need_pay
        unique_id: electricity_need_pay
        state: "{{ state_attr('sensor.electricity_95598', 'need_pay') }}"
        unit_of_measurement: "CNY"
        device_class: monetary
        
      - name: thismonth_electricity_usage_entity
        unique_id: thismonth_electricity_usage_entity
        state: "{{ state_attr('sensor.electricity_95598', 'thismonth_electricity_usage') }}"
        state_class: measurement
        unit_of_measurement: "kWh"
        
      - name: electricity_last_date_entity
        unique_id: electricity_last_date_entity
        state: "{{ state_attr('sensor.electricity_95598', 'last_date') }}"
```

如果你有多个户号，每个户号参照以下配置

```yaml
template:
  - trigger:
      - platform: event
        event_type: "state_changed"
        event_data: 
          entity_id: sensor.electricity_95598_户号
    sensor:
      - name: electricity_charge_balance_entity_户号
        unique_id: electricity_charge_balance_entity_户号
        state: "{{ states('sensor.electricity_95598_户号') }}"
        unit_of_measurement: "CNY"
        device_class: monetary

      - name: electricity_balance_is_pay_entity_户号
        unique_id: electricity_balance_is_pay_entity_户号
        state: "{{ state_attr('sensor.electricity_95598_户号', 'is_pay') }}"
 
      - name: last_electricity_usage_entity_户号
        unique_id: last_electricity_usage_entity_户号
        state: "{{ state_attr('sensor.electricity_95598_户号', 'last_electricity_usage') }}"
        state_class: measurement
        unit_of_measurement: "kWh"

      - name: yearly_electricity_usage_entity_户号
        unique_id: yearly_electricity_usage_entity_户号
        state: "{{ state_attr('sensor.electricity_95598_户号', 'yearly_electricity_usage') }}"
        state_class: measurement
        unit_of_measurement: "kWh"

      - name: yearly_electricity_charge_entity_户号
        unique_id: yearly_electricity_charge_entity_户号
        state: "{{ state_attr('sensor.electricity_95598_户号', 'yearly_electricity_charge') }}"
        unit_of_measurement: "CNY"
        device_class: monetary
        
      - name: electricity_need_pay_户号
        unique_id: electricity_need_pay_户号
        state: "{{ state_attr('sensor.electricity_95598_户号', 'need_pay') }}"
        unit_of_measurement: "CNY"
        device_class: monetary
        
      - name: thismonth_electricity_usage_entity_户号
        unique_id: thismonth_electricity_usage_entity_户号
        state: "{{ state_attr('sensor.electricity_95598_户号', 'thismonth_electricity_usage') }}"
        state_class: measurement
        unit_of_measurement: "kWh"
        
      - name: electricity_last_date_entity_户号
        unique_id: electricity_last_date_entity_户号
        state: "{{ state_attr('sensor.electricity_95598_户号', 'last_date') }}"
```


### 使用方法一：直接作为add-on接入

__如果你是采用supervised, HAOS方式部署的home-assistant（也就是说你部署了suppervisor, add-on等容器），可以使用local add-on的方式接入.__

在webUI上点击配置-》加载项-》加载项商店，加载项商店右上角点击仓库，添加：https://github.com/dscao/npc-hass-addons 。然后回到加载项商店就出现 selenium_electricity，

安装好后，配置好用户名、密码，直接启动即可。稍等1分钟后，就可以在HA中找到本说明开篇写的实体了。


### 使用方法二：docker部署

__如果你是采用core, docker方式部署的home-assistant（也就是说你没有部署suppervisor, add-on等容器），建议采用docker部署本应用。__

首先请在HA webUI上建立一个长期访问令牌，点击webUI左下角用户名拉到最下面就可以看到了。

docker运行：

```bash
docker run --name sgcc_electricity -d -e PHONE_NUMBER="" -e PASSWORD="" -e HASS_URL="" -e HASS_TOKEN="" --restart unless-stopped dscao/sgcc_electricity
```
由于这个镜像较大（docker image约1.17GB），过程较慢。

部署container成功后稍等1分钟，你就可以在HA中找到本说明开篇写的实体了。
