## Серверная часть приложения для чтения Псалтири в Лествице ##

*API-сервер на Vibe.d*

## MySQL ##
```BASH
mysql> create database api_db; -- Creates the new database
mysql> create user 'api'@'localhost' identified by 'LestvitsaDev'; -- Creates the user
mysql> grant all on api_db.* to 'api'@'localhost'; -- Gives all privileges to the new user on the newly created database

*mysql> ALTER USER 'api'@'localhost' IDENTIFIED WITH mysql_native_password BY 'LestvitsaDev';
*mysql> FLUSH PRIVILEGES;
```
Подключение к консольному клиенту
$ mysql -u api -p

## Build ##
```BASH
time dub build && dub run 
```
Новый компоновщик ускоряет сборку в 4 раза 
```BASH
update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.gold" 20
```

### Остановка приложения ###
```BASH
ps ax | grep api-server | cut -f 2 -d " " | cut -d $'\n' -f 1 > kill -n 
```

## README ##

This README would normally document whatever steps are necessary to get your application up and running.

### What is this repository for? ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### How do I get set up? ###

* Summary of set up
* Configuration
* Dependencies
* Database configuration
* How to run tests
* Deployment instructions

### Contribution guidelines ###

* Writing tests
* Code review
* Other guidelines

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact
