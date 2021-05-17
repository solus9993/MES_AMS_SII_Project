# syntax=docker/dockerfile:1
#docker run -it --rm --name rabbitmq 
#-p 5672:5672 -p 15672:15672 -p 15674:15674  -p 15670:15670 -p 61613:61613 rabbitmq:3-management  
FROM rabbitmq:3-management-alpine

RUN rabbitmq-plugins enable --offline rabbitmq_management
RUN rabbitmq-plugins enable --offline rabbitmq_stomp
RUN rabbitmq-plugins enable --offline rabbitmq_web_stomp

# Password is provided as a command line argument.
# Note that certain characters such as $, &, &, #, and so on must be escaped to avoid
# special interpretation by the shell.
RUN rabbitmqctl add_user 'cenas' 'cenas'

EXPOSE 5672 15670 15671 15672 15674 61613