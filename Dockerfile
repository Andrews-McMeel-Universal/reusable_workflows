FROM ubuntu 

RUN apt update

RUN apt install –y apache2 apache2-utils 

RUN apt clean 

EXPOSE 3000

CMD [“apache2ctl”, “-D”, “FOREGROUND”]

